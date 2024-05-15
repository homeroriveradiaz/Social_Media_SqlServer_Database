USE ReadWrite_Prod;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***** VERSION 2 ******/
CREATE OR ALTER PROCEDURE dbo.ETL_PublicSearch_PostingsList_UpdatePostingsList(
	@IPAddress DECIMAL(38, 0)
	, @IpAddressProtocol TINYINT
	, @LanguageID INT
	, @SearchWords [dbo].[SearchWordsIDs] READONLY
	, @PublicSearchListID BIGINT OUTPUT
) AS 


DECLARE @MaximumPerList SMALLINT = 1000 -- The maximum number of postings per list that is allowed.
	, @PostingsRemaining SMALLINT
	, @CityID INT
	, @ComputeList BIT = 0
	, @ListLastUpdate SMALLDATETIME;

/***********************************************************************************

0. If somebody paid, we show them first
1. We find the City this IP Range belongs to.
2. With City and SearchWords in hand, we find out if a list exists
	2.1 If a list does not exist, we create one.
	2.1 We compute the list for the first time.
3. If the list exists, and more than 15 minutes have passed, we update the list.
4. We return the list ID so the parent SP retrieves the postings.

***********************************************************************************/


-- Point #1
IF EXISTS(SELECT 1 FROM dbo.IPAddress_VS_Location WITH(NOLOCK) WHERE @IPAddress BETWEEN FromIp AND ToIP AND IPAddressVersionID = @IpAddressProtocol) BEGIN
	
	SELECT TOP 1 @CityID = CityID
	FROM dbo.IPAddress_VS_Location WITH(NOLOCK)
	WHERE @IPAddress BETWEEN FromIp AND ToIP
		AND IPAddressVersionID = @IpAddressProtocol;

END; ELSE BEGIN --Just in case a location is not found
	
	DECLARE @IPAddressVersionsStr VARCHAR(10) = 
		CASE @IpAddressProtocol 
			WHEN 1 THEN 'v4' 
			WHEN 2 THEN 'v6' 
		END;

	EXEC dbo.LocationSearch_Get_LocationBasedOnIP
		@IPAddress = @IpAddress
		, @IPAddressVersion = @IPAddressVersionsStr
		, @CityID = @CityID OUTPUT;

END;



-- Point #2
SELECT @PublicSearchListID = PSL.PublicSearchListID, @ListLastUpdate = PSL.LastUpdatedDate
FROM dbo.PublicSearchLists AS PSL
WHERE PSL.CityID = @CityID
	AND EXISTS(
		SELECT 1
		FROM (
			SELECT PSLSW.SearchWordID
			FROM dbo.PublicSearchLists_SearchWords AS PSLSW
			WHERE PSL.PublicSearchListID = PSLSW.PublicSearchListID
		) AS X
		FULL JOIN @SearchWords AS SW ON X.SearchWordID = SW.SearchwordID
			HAVING COUNT(*) = COUNT(X.SearchwordID)
				AND COUNT(*) = COUNT(SW.SearchwordID)
	);



IF @PublicSearchListID IS NULL BEGIN --if no list exists, we create one
	
	INSERT INTO dbo.PublicSearchLists(LanguageID, CityID, CreatedDate, LastUpdatedDate)
	VALUES (@LanguageID, @CityID, GETUTCDATE(), GETUTCDATE());

	SET @PublicSearchListID = SCOPE_IDENTITY();

	INSERT INTO dbo.PublicSearchLists_SearchWords(PublicSearchListID, SearchWordID)
	SELECT @PublicSearchListID, SearchwordID
	FROM @SearchWords
	ORDER BY SearchwordID;

	SET @ComputeList = 1;
END;



-- Point #3
IF (@ComputeList = 1 OR DATEDIFF(MINUTE, @ListLastUpdate, GETUTCDATE()) > 10) BEGIN --IF WE JUST CREATED THE LIST OR THE LIST IS OLDER THAN 30 MINUTES, GO AHEAD AND PROCESS

	--1st hierarchy, by exact city match and by searcwords in the posting body
	SELECT DISTINCT TOP (1000) PL.PostingID
		INTO #TEMP
	FROM [dbo].[Postings_Locations] AS PL
	JOIN [dbo].[PostingsSearchWordsList] AS PSWL ON PSWL.PostingID = PL.PostingID
	WHERE PL.CityID = @CityID
		AND PL.Active = 1
		AND PSWL.SearchWordID IN (
			SELECT SearchwordID
			FROM @SearchWords
		)
	ORDER BY PL.PostingID DESC;

	SET @PostingsRemaining = @MaximumPerList - @@ROWCOUNT;
	IF @PostingsRemaining > 0 BEGIN
		
		--2nd hierarchy by cities in the vicinity and by searchwords
		INSERT INTO #TEMP(PostingID)
		SELECT DISTINCT TOP (@PostingsRemaining) PL.PostingID
		FROM [dbo].[Location_Cities_Latitude_Longitude] AS LCLL --ON
		JOIN [dbo].[Location_Cities_Latitude_Longitude] AS BOUNDARIES ON
			LCLL.AvgLatitude BETWEEN BOUNDARIES.AvgLatitudeLowerLimit1 AND BOUNDARIES.AvgLatitudeUpperLimit1
			AND LCLL.AvgLongitude BETWEEN BOUNDARIES.AvgLongitudeLeftmostLimit1 AND BOUNDARIES.AvgLongitudeRightmostLimit1
		JOIN dbo.Postings_Locations AS PL ON PL.CityID = BOUNDARIES.CityID
		JOIN dbo.PostingsSearchWordsList AS PSWL ON PSWL.PostingID = PL.PostingID
		WHERE LCLL.CityID = @CityID
			AND PL.Active = 1
			AND PSWL.SearchWordID IN (
				SELECT SearchwordID
				FROM @SearchWords
			)
			AND PL.PostingID NOT IN (
				SELECT PostingID
				FROM #TEMP
			)
		ORDER BY PL.PostingID DESC;

							   				 
		SET @PostingsRemaining = @PostingsRemaining - @@ROWCOUNT;
		IF @PostingsRemaining > 0 BEGIN
			--3rd hierarchy by users whose description fits the search words and are in the vicinity

			DECLARE @LongitudeLeftLimit FLOAT, @LongitudeRightLimit FLOAT
				, @LatitudeUpperLimit FLOAT, @LatitudeLowerLimit FLOAT;

			SELECT @LongitudeLeftLimit = MAX([AvgLongitudeLeftmostLimit1])
				, @LongitudeRightLimit = MAX([AvgLongitudeRightmostLimit1])
				, @LatitudeUpperLimit = MAX([AvgLatitudeUpperLimit1])
				, @LatitudeLowerLimit = MAX([AvgLatitudeLowerLimit1])
			FROM [dbo].[Location_Cities_Latitude_Longitude]
			WHERE CityID = @CityID;
			
			INSERT INTO #TEMP(PostingID)
			SELECT DISTINCT TOP (@PostingsRemaining) P.PostingID
			FROM dbo.Users AS U
			JOIN dbo.User_DescriptionSplitToSearchWords AS UDSW ON U.UserID = UDSW.UserID
			JOIN dbo.Postings AS P ON U.UserID = P.PostedByUserID
			JOIN dbo.Postings_Locations AS PL ON P.PostingID = PL.PostingID
			JOIN [dbo].[Location_Cities_Latitude_Longitude] AS LCLL ON PL.CityID = LCLL.CityID
			WHERE U.Active = 1
				AND U.Censored = 0
				AND P.Active = 1 AND PL.Active = 1
				AND UDSW.SearchWordID IN (SELECT SearchwordID FROM @SearchWords)
				AND LCLL.AvgLatitude BETWEEN @LatitudeLowerLimit AND @LatitudeUpperLimit AND LCLL.AvgLongitude BETWEEN @LongitudeLeftLimit AND @LongitudeRightLimit				
				AND P.PostingID NOT IN (
					SELECT PostingID
					FROM #TEMP
				);

			--SET @PostingsRemaining = @PostingsRemaining - @@ROWCOUNT;
			--IF @PostingsRemaining > 0 BEGIN
			--	--4th hierarchy, whatever is away by radius of +1000km
			--	INSERT INTO #TEMP(PostingID)
			--	SELECT DISTINCT TOP (@PostingsRemaining) PL.PostingID
			--	FROM [dbo].[Location_Cities_Latitude_Longitude] AS LCLL --ON
			--	JOIN [dbo].[Location_Cities_Latitude_Longitude] AS BOUNDARIES ON
			--		LCLL.AvgLatitude BETWEEN BOUNDARIES.AvgLatitudeLowerLimit2 AND BOUNDARIES.AvgLatitudeUpperLimit2
			--		AND LCLL.AvgLongitude BETWEEN BOUNDARIES.AvgLongitudeLeftmostLimit2 AND BOUNDARIES.AvgLongitudeRightmostLimit2
			--	JOIN dbo.Postings_Locations AS PL ON PL.CityID = BOUNDARIES.CityID
			--	JOIN dbo.PostingsSearchWordsList AS PSWL ON PSWL.PostingID = PL.PostingID
			--	WHERE LCLL.CityID = @CityID
			--		AND PL.Active = 1
			--		AND PSWL.SearchWordID IN (
			--			SELECT SearchwordID
			--			FROM @SearchWords
			--		)
			--		AND PL.PostingID NOT IN (
			--			SELECT PostingID
			--			FROM #TEMP
			--		)
			--	ORDER BY PL.PostingID DESC;


			--	SET @PostingsRemaining = @PostingsRemaining - @@ROWCOUNT;
			--	IF @PostingsRemaining > 0 BEGIN
			--		--5th hierarchy: by users whose description fits the search words and are out of the vicinity and within +1000Kms away
			--		SELECT @LongitudeLeftLimit = MAX([AvgLongitudeLeftmostLimit2])
			--			, @LongitudeRightLimit = MAX([AvgLongitudeRightmostLimit2])
			--			, @LatitudeUpperLimit = MAX([AvgLatitudeUpperLimit2])
			--			, @LatitudeLowerLimit = MAX([AvgLatitudeLowerLimit2])
			--		FROM [dbo].[Location_Cities_Latitude_Longitude]
			--		WHERE CityID = @CityID;
			
			--		INSERT INTO #TEMP(PostingID)
			--		SELECT DISTINCT TOP (@PostingsRemaining) P.PostingID
			--		FROM dbo.Users AS U
			--		JOIN dbo.User_DescriptionSplitToSearchWords AS UDSW ON U.UserID = UDSW.UserID
			--		JOIN dbo.Postings AS P ON U.UserID = P.PostedByUserID
			--		JOIN dbo.Postings_Locations AS PL ON P.PostingID = PL.PostingID
			--		JOIN [dbo].[Location_Cities_Latitude_Longitude] AS LCLL ON PL.CityID = LCLL.CityID
			--		WHERE U.Active = 1
			--			AND U.Censored = 0
			--			AND P.Active = 1 AND PL.Active = 1
			--			AND UDSW.SearchWordID IN (SELECT SearchwordID FROM @SearchWords)
			--			AND LCLL.AvgLatitude BETWEEN @LatitudeLowerLimit AND @LatitudeUpperLimit AND LCLL.AvgLongitude BETWEEN @LongitudeLeftLimit AND @LongitudeRightLimit				
			--			AND P.PostingID NOT IN (
			--				SELECT PostingID
			--				FROM #TEMP
			--			);
			--	END;

			--END;

		END;



	END;


	DELETE PSLP
	FROM dbo.PublicSearchLists_Postings AS PSLP
	LEFT JOIN #TEMP AS T ON PSLP.PostingID = T.PostingID
	WHERE PSLP.PublicSearchListID = @PublicSearchListID
		AND T.PostingID IS NULL;

	INSERT INTO dbo.PublicSearchLists_Postings(PublicSearchListID, PostingID)
	SELECT @PublicSearchListID, T.PostingID
	FROM #TEMP AS T 
	LEFT JOIN dbo.PublicSearchLists_Postings AS PSLP ON T.PostingID = PSLP.PostingID 
		AND PSLP.PublicSearchListID = @PublicSearchListID
	WHERE PSLP.PostingID IS NULL;

	UPDATE dbo.PublicSearchLists
	SET LastUpdatedDate = GETUTCDATE()
	WHERE PublicSearchListID = @PublicSearchListID;

END;


-- Point #4
-- @PublicSearchListID already populated
-- Have a nice day!

RETURN;


GO
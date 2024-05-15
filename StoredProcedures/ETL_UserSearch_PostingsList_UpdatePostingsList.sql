USE ReadWrite_Prod;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***** VERSION 2 ******/
CREATE OR ALTER PROCEDURE dbo.ETL_UserSearch_PostingsList_UpdatePostingsList(
	@UserID BIGINT
	, @LanguageId INT
) AS 



DECLARE @MaximumPerList SMALLINT = 1000 -- The maximum number of postings per list that is allowed.
	, @PostingsRemaining SMALLINT
	, @DefaultClasificAdsAccount BIGINT; -- Account used to stay in touch with subscribers
	

SET @DefaultClasificAdsAccount = 
	CASE @LanguageId
		WHEN 2 THEN -9223372036854775763
		ELSE -9223372036854775763
	END;


SELECT PostingID
	INTO #SavedPostings
FROM dbo.User_SavedPostings AS USP
WHERE UserID = @UserID;
	



/*******************************************************
	CREATE BASE TABLE TO JOIN USER-SPECIFIC ITEMS
*******************************************************/
SELECT UL.UserID, USW.SearchWordID, UL.CityID
	, LCLL.AvgLatitude, LCLL.AvgLongitude
	INTO #TMPUSR
FROM [dbo].[User_LocationsFollowed] AS UL
JOIN [dbo].[User_SearchWords] AS USW ON UL.UserID = USW.UserID
JOIN [dbo].[Location_Cities_Latitude_Longitude] AS LCLL ON UL.CityID = LCLL.CityID
WHERE UL.UserID = @UserID



/*********************************************************************************************
	
	CRITERIA "ZERO" TO SHOW POSTINGS IS:
		-Show those who paid based on search words

		THIS PART OF THE ALGORITHM IS YET TO BE WRITTEN...

*********************************************************************************************/





/*********************************************************************************************

	FIRST CRITERIA TO SHOW POSTINGS:
		a. The postings created by followed users (includind the ClasificAds user for their language), and...
		b. Postings that match search words and cities we follow.

*********************************************************************************************/
SELECT TOP (@MaximumPerList)
	PostingID, CAST(1 AS tinyint) AS ListHierarchy
INTO #TEMP
FROM (
	SELECT PL.PostingID
	FROM #TMPUSR AS vUP
	JOIN dbo.Postings_Locations AS PL ON vUP.CityID = PL.CityID
	JOIN dbo.PostingsSearchWordsList AS PSWL ON PL.PostingID = PSWL.PostingID
		AND vUP.SearchWordID = PSWL.SearchWordID
	WHERE PL.Active = 1		
		AND PL.PostingID NOT IN (
			SELECT PostingID
			FROM #SavedPostings
		)
		UNION
	SELECT vwP.PostingID
	FROM (
			SELECT UserIDFollowed
			FROM [dbo].[User_UsersFollowed]
			WHERE UserID = @UserID
				AND IsMute = 0
				UNION
			SELECT @DefaultClasificAdsAccount AS UserIDFollowed
	) AS UF
	JOIN [dbo].[vw_postings_raw_data_for_search_lists] AS vwP ON UF.UserIDFollowed = vwP.PostedByUserID
	WHERE vwP.PostingActive = 1
		AND vwP.PostingCensored = 0
		AND vwP.PostingUserActive = 1
		AND vwP.PostingUserCensored = 0
		AND vwP.PostingID NOT IN (
			SELECT PostingID
			FROM #SavedPostings
		)
) AS X
ORDER BY PostingID;


SET @PostingsRemaining = 1000 - @@ROWCOUNT;


/*********************************************************************************************

	SECOND CRITERIA TO SHOW POSTINGS:
		c. Postings that match search words and are in the vicinities, but not in the exact cities we follow (1 degree radius from the cities we follow, subject to change)

*********************************************************************************************/
IF @PostingsRemaining > 0 BEGIN
	
	INSERT INTO #TEMP(PostingID, ListHierarchy)
	SELECT DISTINCT TOP(@PostingsRemaining)
		PL.PostingID, CAST(2 AS tinyint) AS ListHierarchy
	FROM #TMPUSR AS vUP
	JOIN dbo.Location_Cities_Latitude_Longitude AS LCLL
		ON vUP.AvgLatitude BETWEEN LCLL.AvgLatitudeLowerLimit1 AND LCLL.AvgLatitudeUpperLimit1 
			AND vUP.AvgLongitude BETWEEN LCLL.AvgLongitudeLeftmostLimit1 AND LCLL.AvgLongitudeRightmostLimit1
	JOIN dbo.Postings_Locations AS PL ON LCLL.CityID = PL.CityID
	JOIN dbo.PostingsSearchWordsList AS PSWL ON PL.PostingID = PSWL.PostingID
		AND vUP.SearchWordID = PSWL.SearchWordID
	WHERE PL.Active = 1
		AND PL.PostingID NOT IN (
			SELECT PostingID
			FROM #TEMP
				UNION
			SELECT PostingID
			FROM #SavedPostings
		)
	ORDER BY PL.PostingID;


	SET @PostingsRemaining = @PostingsRemaining - @@ROWCOUNT;
	
END;




/*********************************************************************************************

	THIRD CRITERIA TO SHOW POSTINGS:
		c. Postings from users in the the vicinity whose description 
			or brand/name or slogan include our search words

*********************************************************************************************/
IF @PostingsRemaining > 0 BEGIN

	INSERT INTO #TEMP(PostingID, ListHierarchy)
	SELECT DISTINCT TOP (@PostingsRemaining)
		P.PostingID, CAST(3 AS tinyint) AS ListHierarchy
	FROM #TMPUSR AS vUP
	JOIN dbo.Users AS U
	JOIN dbo.Location_Cities_Latitude_Longitude AS LCLL ON U.BaseCityID = LCLL.CityID
		ON vUP.AvgLatitude BETWEEN LCLL.AvgLatitudeLowerLimit1 AND LCLL.AvgLatitudeUpperLimit1
			AND vUP.AvgLongitude BETWEEN LCLL.AvgLongitudeLeftmostLimit1 AND LCLL.AvgLongitudeRightmostLimit1
	JOIN dbo.User_DescriptionSplitToSearchWords AS DSSW ON U.UserID = DSSW.UserID
		AND vUP.SearchWordID = DSSW.SearchWordID
	JOIN dbo.Postings AS P ON U.UserID = P.PostedByUserID
	WHERE U.Active = 1
		AND U.Censored = 0
		AND P.Active = 1
		AND P.Censored = 0
		AND P.PostingID NOT IN (
			SELECT PostingID
			FROM #TEMP
				UNION
			SELECT PostingID
			FROM #SavedPostings
		);


	SET @PostingsRemaining = @PostingsRemaining - @@ROWCOUNT;

END;

/******************************************************************************************************

	FOURTH CRITERIA TO SHOW POSTINGS:
		d. since nothing could fill the total postings allowed per list, then, we need to expand the 
		search 	area, but make these findings not as relevant as the first ones we found.
		These postings could be over 1000 KMs away.

*******************************************************************************************************/
IF @PostingsRemaining > 0 BEGIN

	INSERT INTO #TEMP(PostingID, ListHierarchy)
	SELECT DISTINCT TOP(@PostingsRemaining)
		PL.PostingID, CAST(4 AS tinyint) AS ListHierarchy
	FROM #TMPUSR AS vUP
	JOIN dbo.Location_Cities_Latitude_Longitude AS LCLL
		ON vUP.AvgLatitude BETWEEN LCLL.AvgLatitudeLowerLimit2 AND LCLL.AvgLatitudeUpperLimit2
			AND vUP.AvgLongitude BETWEEN LCLL.AvgLongitudeLeftmostLimit2 AND LCLL.AvgLongitudeRightmostLimit2
	JOIN dbo.Postings_Locations AS PL ON LCLL.CityID = PL.CityID
	JOIN dbo.PostingsSearchWordsList AS PSWL ON PL.PostingID = PSWL.PostingID
		AND vUP.SearchWordID = PSWL.SearchWordID
	WHERE PL.Active = 1
		AND PL.PostingID NOT IN (
			SELECT PostingID
			FROM #TEMP
				UNION
			SELECT PostingID
			FROM #SavedPostings
		)
	ORDER BY PL.PostingID;

	SET @PostingsRemaining = @PostingsRemaining - @@ROWCOUNT;

END;



/*********************************************************************************************

	FIFTH CRITERIA TO SHOW POSTINGS:
		c. Postings from users out of the vicinity, as away as +1000Kms whose description 
			or brand/name or slogan include our search words

*********************************************************************************************/
IF @PostingsRemaining > 0 BEGIN

	INSERT INTO #TEMP(PostingID, ListHierarchy)
	SELECT DISTINCT TOP (@PostingsRemaining)
		P.PostingID, CAST(3 AS tinyint) AS ListHierarchy
	FROM #TMPUSR AS vUP
	JOIN dbo.Users AS U
		JOIN dbo.Location_Cities_Latitude_Longitude AS LCLL ON U.BaseCityID = LCLL.CityID
		ON vUP.AvgLatitude BETWEEN LCLL.AvgLatitudeLowerLimit2 AND LCLL.AvgLatitudeUpperLimit2
			AND vUP.AvgLongitude BETWEEN LCLL.AvgLongitudeLeftmostLimit2 AND LCLL.AvgLongitudeRightmostLimit2
	JOIN dbo.User_DescriptionSplitToSearchWords AS DSSW ON U.UserID = DSSW.UserID
		AND vUP.SearchWordID = DSSW.SearchWordID
	JOIN dbo.Postings AS P ON U.UserID = P.PostedByUserID
	WHERE U.Active = 1
		AND U.Censored = 0
		AND P.Active = 1
		AND P.Censored = 0
		AND P.PostingID NOT IN (
			SELECT PostingID
			FROM #TEMP
				UNION
			SELECT PostingID
			FROM #SavedPostings
		);

END;



DELETE UPP
FROM [dbo].[User_PinboardPostings] AS UPP
LEFT JOIN #TEMP AS T ON UPP.PostingID = T.PostingID
WHERE UPP.UserID = @UserID
	AND T.PostingID IS NULL;

INSERT INTO [dbo].[User_PinboardPostings](UserID, PostingID, ListHierarchy)
SELECT @UserID, T.PostingID, T.ListHierarchy
FROM #TEMP AS T
LEFT JOIN dbo.User_PinboardPostings AS UPP ON UPP.UserID = @UserID 
	AND T.PostingID = UPP.PostingID
WHERE UPP.UserID IS NULL;


GO





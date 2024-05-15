USE ReadWrite_Prod;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***** VERSION 2 ******/
CREATE OR ALTER PROCEDURE CategoriesSearch.ETL_PublicSearch_PostingsList_UpdatePostingsList(
	@IPAddress DECIMAL(38, 0)
	, @IpAddressProtocol TINYINT
	, @ChildCategoryID INT
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
SELECT @PublicSearchListID = PSL.PublicSearchLists_ChildCategories_ID
	, @ListLastUpdate = PSL.LastUpdatedDate
FROM CategoriesSearch.PublicSearchLists_ChildCategories PSL
WHERE PSL.CityID = @CityID
	AND PSL.ChildCategoryID = @ChildCategoryID;


IF @PublicSearchListID IS NULL BEGIN --if no list exists, we create one
	
	INSERT INTO CategoriesSearch.PublicSearchLists_ChildCategories(ChildCategoryID, CityID, CreatedDate, LastUpdatedDate)
	VALUES (@ChildCategoryID, @CityID, GETUTCDATE(), GETUTCDATE());

	SET @PublicSearchListID = SCOPE_IDENTITY();

	SET @ComputeList = 1;
END;



-- Point #3
IF (@ComputeList = 1 OR DATEDIFF(MINUTE, @ListLastUpdate, GETUTCDATE()) > 10) BEGIN --IF WE JUST CREATED THE LIST OR THE LIST IS OLDER THAN 30 MINUTES, GO AHEAD AND PROCESS






	--1st hierarchy, by exact city match and by searcwords in the posting body
	SELECT DISTINCT TOP (1000) PL.PostingID
		INTO #TEMP
	FROM [dbo].[Postings_Locations] AS PL
	JOIN [dbo].[PostingsCategories] AS PC ON PL.PostingID = PC.PostingID
	WHERE PL.CityID = @CityID
		AND PL.Active = 1
		AND PC.ChildCategoryID = @ChildCategoryID
	ORDER BY PL.PostingID DESC;



	SET @PostingsRemaining = @MaximumPerList - @@ROWCOUNT;
	IF @PostingsRemaining > 0 BEGIN
		
		--2nd hierarchy by cities in the vicinity and by categories
		INSERT INTO #TEMP(PostingID)
		SELECT DISTINCT TOP (@PostingsRemaining) PL.PostingID
		FROM [dbo].[Location_Cities_Latitude_Longitude] AS LCLL
		JOIN [dbo].[Location_Cities_Latitude_Longitude] AS BOUNDARIES ON
			LCLL.AvgLatitude BETWEEN BOUNDARIES.AvgLatitudeLowerLimit1 AND BOUNDARIES.AvgLatitudeUpperLimit1
			AND LCLL.AvgLongitude BETWEEN BOUNDARIES.AvgLongitudeLeftmostLimit1 AND BOUNDARIES.AvgLongitudeRightmostLimit1
		JOIN dbo.Postings_Locations AS PL ON PL.CityID = BOUNDARIES.CityID
		JOIN dbo.PostingsCategories AS PC ON PC.PostingID = PL.PostingID
		WHERE LCLL.CityID = @CityID
			AND PL.Active = 1
			AND PC.ChildCategoryID = @ChildCategoryID
			AND PL.PostingID NOT IN (
				SELECT PostingID
				FROM #TEMP
			)
		ORDER BY PL.PostingID DESC;

	END;



--CREATE TABLE CategoriesSearch.PublicSearchLists_ChildCategories
--(
--	PublicSearchLists_ChildCategories_ID BIGINT IDENTITY(-9223372036854775808, 1) NOT NULL
--	, ChildCategoryID INT NOT NULL
--	, CityID INT NOT NULL
--	, CreatedDate SMALLDATETIME
--	, LastUpdatedDate SMALLDATETIME
--);
--CREATE TABLE CategoriesSearch.PublicSearchLists_ChildCategories_Postings(
--	PublicSearchLists_ChildCategories_ID BIGINT
--	, PostingID BIGINT
--);



	DELETE PSLP
	FROM CategoriesSearch.PublicSearchLists_ChildCategories_Postings AS PSLP
	LEFT JOIN #TEMP AS T ON PSLP.PostingID = T.PostingID
	WHERE PSLP.PublicSearchLists_ChildCategories_ID = @PublicSearchListID
		AND T.PostingID IS NULL;

	INSERT INTO CategoriesSearch.PublicSearchLists_ChildCategories_Postings(PublicSearchLists_ChildCategories_ID, PostingID)
	SELECT @PublicSearchListID, T.PostingID
	FROM #TEMP AS T 
	LEFT JOIN CategoriesSearch.PublicSearchLists_ChildCategories_Postings AS PSLP ON T.PostingID = PSLP.PostingID 
		AND PSLP.PublicSearchLists_ChildCategories_ID = @PublicSearchListID
	WHERE PSLP.PostingID IS NULL;

	UPDATE CategoriesSearch.PublicSearchLists_ChildCategories
	SET LastUpdatedDate = GETUTCDATE()
	WHERE PublicSearchLists_ChildCategories_ID = @PublicSearchListID;

END;

RETURN;


GO
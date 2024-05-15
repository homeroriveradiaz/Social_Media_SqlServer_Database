USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[User_PostMessageWithQuote]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO


IF OBJECT_ID(N'Postings_Add_Posting', N'P') IS NULL BEGIN
	EXEC('CREATE PROC dbo.Postings_Add_Posting AS SELECT 1;');
END;
GO


/***************************************************************************
CREATES A POSTING FOR A USER
1: normal posting
2: report follow-up (not created by user, but by the staff
***************************************************************************/
ALTER PROCEDURE [dbo].[Postings_Add_Posting](
	@PostingTypeID TINYINT = 1
	, @UserID BIGINT
	, @MessageTitle NVARCHAR(100)
	, @MessageBody NVARCHAR(4000)
	, @IPAddress BIGINT
	, @Price MONEY = NULL
	, @PriceCurrencyID INT = NULL
	, @ImagesString NVARCHAR(4000) = NULL
	, @LocationsString NVARCHAR(4000) = NULL
	, @ChildCategoryID INT
)
AS



/***************************************************************************
	PART I.
	CREATE THE POSTING AND GET THE POSTING ID

***************************************************************************/
DECLARE @PostingID BIGINT;


IF (@Price IS NULL) BEGIN
	SELECT @Price = NULL;
END;


INSERT INTO dbo.Postings (
	PostingTypeID, PostedByUserID, PostDateTime
	, PostingTitle, PostingMessage, FromIPAddress
	, Price, PriceCurrencyID
	, Censored, Active)
VALUES (
	@PostingTypeID, @UserID, GETDATE()
	, @MessageTitle, @MessageBody, @IPAddress
	, @Price, @PriceCurrencyID
	, 0, 1
)

SET @PostingID =  SCOPE_IDENTITY();

/***********************************************************************
	PART II.
	SET THE CATEGORY OF THE POSTING
***********************************************************************/
INSERT INTO dbo.PostingsCategories(PostingID, ChildCategoryID)
VALUES (@PostingID, @ChildCategoryID);



/***********************************************************************
	PART III.
	IF POSTING IS NORMAL (TYPE 1) THEN PROVISION ALL
	IMAGES, LOCATIONS, HASHTAGS AND PROD-NOTIFICATIONS.

		...also update user defaults as to show quote when posting and stuff.

***********************************************************************/
IF (@PostingTypeID = 1) BEGIN
	

	/*********************************************************************
		PART III.A
		ATTACH IMAGES

	*********************************************************************/
	EXEC dbo.Postings_Add_ImagesToPosting
		@PostingID = @PostingID
		, @ImagesString = @ImagesString
		, @UserID = @UserID;




	/*********************************************************************
		PART III.B
		ASSIGN LOCATIONS

	*********************************************************************/
	BEGIN TRY
		
		EXEC dbo.Postings_Add_LocationsToPosting
			@PostingID = @PostingID
			, @LocationsString = @LocationsString;

	END TRY
	BEGIN CATCH
		
		UPDATE dbo.Postings
		SET Active = 0
		WHERE PostingID = @PostingID;

		DECLARE @Error NVARCHAR(4000) = 'An attempt to create a posting ' + CAST(@PostingID AS NVARCHAR) + ' by userid ' + CAST(@UserID AS NVARCHAR) +  ' failed because of a violation in locations. The posting was deactivated to avoid any issues and has not been flagged for processing or hashtags.';

		RAISERROR(@Error, 16, 1);
		RETURN;

	END CATCH;



	/*********************************************************************
		PART III.C
		COLLECT WORDS FOR SEARCH LISTS, ALSO COVERS #HASHTAGS

	*********************************************************************/
	EXEC dbo.Postings_Collect_Words
		@PostingID = @PostingID
		, @MessageTitle = @MessageTitle
		, @MessageBody = @MessageBody;



	/***********************************************************************
		PART III.D
		CHANGE USER DEFAULTS IF APPLICABLE

	***********************************************************************/
	--UPDATE CURRENCY AND SHOWQUOTE IF APPLICABLE
	IF (@Price IS NOT NULL)
		AND (NOT EXISTS(
			SELECT 1 FROM
			dbo.Users WITH(NOLOCK)
			WHERE UserID = @UserID
				AND DefaultCurrencyID = @PriceCurrencyID)
	) BEGIN
		UPDATE dbo.Users
		SET DefaultCurrencyID = @PriceCurrencyID
		WHERE UserID = @UserID;
	END;



END;


/*******************************************************
	PART IV.
	RETURN THE POSTING JSON

*******************************************************/
DECLARE @LanguageID INT
	, @MediaURL VARCHAR(200) = dbo.fn_Get_Media_URL();

SELECT @LanguageID = DefaultLanguageID
FROM dbo.Users
WHERE UserID = @UserID;

SELECT ISNULL((
	SELECT CAST(VP.PostingID AS VARCHAR) AS postingId, VP.PostingTitle AS postingTitle, VP.PostingMessage AS postingMessage
		, dbo.fnha_ui_how_long_since_posting(VP.PostDateTime, @LanguageID) AS postedOn
		, VP.Price AS price, VP.CurrencySymbol AS currencySymbol, VP.CurrencyAbbreviation AS currencyAbbreviation
		, @MediaURL + VP.Avatar AS avatar, CAST(VP.PostedByUserID AS VARCHAR) AS postedByUserId, VP.[Name] AS [name]
		, (ISNULL((
			SELECT @MediaURL + I.[Image] AS [image]
			FROM dbo.Postings_AttachedImages AS AI
			INNER JOIN dbo.Images AS I ON AI.ImageId = I.ImageId
			WHERE AI.PostingID = VP.PostingID
			FOR JSON AUTO
		), '[]')) AS images
		, (ISNULL((
			SELECT ULS.FullCityName_State_Country AS location
			FROM dbo.Postings_Locations AS PL
			INNER JOIN dbo.UserLocationsSearch  AS ULS ON PL.CountryID = ULS.CountryID
				AND PL.StateID = ULS.StateID
				AND PL.CityID = ULS.CityID
			WHERE PL.PostingID = VP.PostingID
			FOR JSON AUTO
		), '[]')) as locations
		, CAST(0 AS BIT) AS hasNotifications
		, (ISNULL((
			SELECT TOP 0 NULL AS thread
			FOR JSON PATH
		), '[]')) as threads
		, (ISNULL((
			SELECT VPCPC.ParentCategoryName + '>' + VPCPC.ChildCategoryName AS category
			FROM dbo.PostingsCategories AS PC
			JOIN dbo.vw_Parent_Child_Postings_Categories AS VPCPC ON PC.ChildCategoryID = VPCPC.ChildCategoryId
			WHERE PC.PostingID = @PostingID
		), '[]')) as categories
	FROM dbo.vw_postings_raw_data_for_search_lists AS VP
	WHERE VP.PostingID = @PostingID
			AND VP.PostingTypeID = 1
			AND VP.PostingActive = 1
			AND VP.PostingCensored = 0
			AND VP.PostingUserActive = 1
			AND VP.PostingUserCensored = 0	
	ORDER BY VP.PostingID DESC
	FOR JSON PATH, ROOT('postings'), INCLUDE_NULL_VALUES
), '{"postings":[]}') AS jsonString;



GO
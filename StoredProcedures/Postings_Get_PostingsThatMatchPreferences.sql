USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[User_ThisUser_GetPostingsThatMatchPreferences]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO


IF OBJECT_ID(N'dbo.Postings_Get_PostingsThatMatchPreferences', N'P') IS NULL BEGIN
	EXEC('CREATE PROC dbo.Postings_Get_PostingsThatMatchPreferences AS SELECT 1;');
END;
GO


ALTER PROCEDURE dbo.Postings_Get_PostingsThatMatchPreferences (
	@UserID BIGINT
	, @LanguageID INT
	, @BelowPostingID BIGINT = NULL
)
AS



IF (@BelowPostingID IS NULL) BEGIN
	EXEC dbo.ETL_UserSearch_PostingsList_UpdatePostingsList
		@UserID  = @UserID
		, @LanguageId  = @LanguageId;
END;



DECLARE @MediaURL VARCHAR(200) = dbo.fn_Get_Media_URL();

IF (@BelowPostingID IS NOT NULL) BEGIN

	SELECT ISNULL((
		SELECT TOP 20 CAST(VP.PostingID AS NVARCHAR) AS postingId, VP.PostingTitle AS postingTitle, VP.PostingMessage AS postingMessage
			, dbo.fnha_ui_how_long_since_posting(VP.PostDateTime, @LanguageID) AS postedOn
			, VP.Price AS price, VP.CurrencySymbol AS currencySymbol
			, VP.CurrencyAbbreviation AS currencyAbbreviation, @MediaURL + VP.Avatar AS avatar, VP.UserPublicKey AS userPublicKey
			, VP.[Name] AS [name]
			, (ISNULL((
				SELECT @MediaURL + I.[Image] AS [image]
				FROM dbo.Postings_AttachedImages AS AI
				INNER JOIN dbo.Images AS I ON AI.ImageId = I.ImageId
				WHERE AI.PostingID = VP.PostingID
				FOR JSON PATH
			), '[]')) AS images
			, (ISNULL((
				SELECT ULS.FullCityName_State_Country AS [location]
				FROM dbo.Postings_Locations AS PL
				INNER JOIN dbo.UserLocationsSearch  AS ULS ON PL.CountryID = ULS.CountryID
					AND PL.StateID = ULS.StateID
					AND PL.CityID = ULS.CityID
				WHERE PL.PostingID = VP.PostingID
				FOR JSON AUTO
			), '[]')) as locations
			, CAST(CASE WHEN VP.PostedByUserID = @UserID THEN 1 ELSE 0 END AS BIT) AS isOwnPosting
		FROM dbo.User_PinboardPostings AS PP WITH(NOLOCK)
			INNER JOIN dbo.vw_postings_raw_data_for_search_lists AS VP ON PP.PostingID = VP.PostingID
			LEFT JOIN dbo.User_UsersFollowed AS UUF WITH(NOLOCK) ON UUF.UserID = @UserID
				AND VP.PostedByUserID = UUF.UserIDFollowed
		WHERE PP.UserID = @UserID
			AND (VP.PostingTypeID = 1
				AND VP.PostingActive = 1
				AND VP.PostingCensored = 0
				AND VP.PostingUserActive = 1
				AND VP.PostingUserCensored = 0
			)
			AND VP.PostingID < @BelowPostingID
			AND VP.PostedByUserID NOT IN (SELECT BannedUserID FROM dbo.User_BannedUsers WITH(NOLOCK) WHERE UserID = @UserID)
			AND VP.PostingID NOT IN (SELECT PostingID FROM dbo.User_SavedPostings WITH(NOLOCK) WHERE UserID = @UserID)
			AND (UUF.IsMute IS NULL OR UUF.IsMute = 0)
		ORDER BY VP.PostingID DESC
		FOR JSON PATH, ROOT('postings'), INCLUDE_NULL_VALUES
	), '{"postings":[]}') AS jsonString;


END; ELSE BEGIN

	SELECT ISNULL((
		SELECT TOP 20 CAST(VP.PostingID AS NVARCHAR) AS postingId, VP.PostingTitle AS postingTitle, VP.PostingMessage AS postingMessage
			, dbo.fnha_ui_how_long_since_posting(VP.PostDateTime, @LanguageID) AS postedOn
			, VP.Price AS price, VP.CurrencySymbol AS currencySymbol
			, VP.CurrencyAbbreviation AS currencyAbbreviation, @MediaURL + VP.Avatar AS avatar, VP.UserPublicKey AS userPublicKey
			, VP.[Name] AS [name]
			, (ISNULL((
				SELECT @MediaURL + I.[Image] AS [image]
				FROM dbo.Postings_AttachedImages AS AI
				INNER JOIN dbo.Images AS I ON AI.ImageId = I.ImageId
				WHERE AI.PostingID = VP.PostingID
				FOR JSON PATH
			), '[]')) AS images
			, (ISNULL((
				SELECT ULS.FullCityName_State_Country AS [location]
				FROM dbo.Postings_Locations AS PL
				INNER JOIN dbo.UserLocationsSearch  AS ULS ON PL.CountryID = ULS.CountryID
					AND PL.StateID = ULS.StateID
					AND PL.CityID = ULS.CityID
				WHERE PL.PostingID = VP.PostingID
				FOR JSON AUTO		
			), '[]')) as locations
			, CAST(CASE WHEN VP.PostedByUserID = @UserID THEN 1 ELSE 0 END AS BIT) AS isOwnPosting
		FROM dbo.User_PinboardPostings AS PP WITH(NOLOCK)
			INNER JOIN dbo.vw_postings_raw_data_for_search_lists AS VP ON PP.PostingID = VP.PostingID
			LEFT JOIN dbo.User_UsersFollowed AS UUF WITH(NOLOCK) ON UUF.UserID = @UserID 
				AND VP.PostedByUserID = UUF.UserIDFollowed
		WHERE PP.UserID = @UserID
			AND (VP.PostingTypeID = 1
				AND VP.PostingActive = 1
				AND VP.PostingCensored = 0
				AND VP.PostingUserActive = 1
				AND VP.PostingUserCensored = 0
			)
			AND VP.PostedByUserID NOT IN (SELECT BannedUserID FROM dbo.User_BannedUsers WITH(NOLOCK) WHERE UserID = @UserID)
			AND VP.PostingID NOT IN (SELECT PostingID FROM dbo.User_SavedPostings WITH(NOLOCK) WHERE UserID = @UserID)
			AND (UUF.IsMute IS NULL OR UUF.IsMute = 0)
		ORDER BY VP.PostingID DESC
		FOR JSON PATH, ROOT('postings'), INCLUDE_NULL_VALUES
	), '{"postings":[]}') AS jsonString;


END;




GO
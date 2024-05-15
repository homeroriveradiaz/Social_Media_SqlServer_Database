USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Get_PostingsThatBelongToAUser]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO


CREATE OR ALTER PROCEDURE [dbo].[Postings_Get_PostingsThatBelongToAUser](
	@UserPublicKey NVARCHAR(200)
	, @UserIDThatSearches BIGINT = NULL
	, @BelowPostingID BIGINT = NULL
	, @LanguageID INT
)
AS

DECLARE @UserID BIGINT = NULL;

SELECT @UserID = UPK.UserID 
FROM dbo.UsersPublicKey AS UPK
INNER JOIN dbo.Users AS U ON UPK.UserID = U.UserID
WHERE UPK.ShortenedNameFull = @UserPublicKey
	AND U.Active = 1
	AND U.Censored = 0;


IF (@UserID IS NOT NULL) BEGIN

	DECLARE @MediaURL VARCHAR(200) = dbo.fn_Get_Media_URL();

	IF (@UserIDThatSearches IS NOT NULL AND @BelowPostingID IS NULL) BEGIN

		SELECT ISNULL((
			SELECT TOP 20 CAST(PRD.PostingID AS VARCHAR) AS postingId, PRD.PostingTitle AS postingTitle, PRD.PostingMessage AS postingMessage
				, dbo.fnha_ui_how_long_since_posting(PRD.PostDateTime, @LanguageID) AS postedOn
				, PRD.Price AS price, PRD.CurrencySymbol AS currencySymbol, PRD.CurrencyAbbreviation AS currencyAbbreviation
				, @MediaURL + PRD.Avatar AS avatar, CAST(PRD.PostedByUserID AS VARCHAR) AS postedByUserId, PRD.[Name] AS name
				, (ISNULL((
					SELECT @MediaURL + I.[Image] AS [image]
					FROM dbo.Postings_AttachedImages AS AI
					INNER JOIN dbo.Images AS I ON AI.ImageId = I.ImageId
					WHERE AI.PostingID = PRD.PostingID
					FOR JSON AUTO
				), '[]')) AS images
				, (ISNULL((
					SELECT ULS.FullCityName_State_Country AS location
					FROM dbo.Postings_Locations AS PL
					INNER JOIN dbo.UserLocationsSearch  AS ULS ON PL.CountryID = ULS.CountryID
						AND PL.StateID = ULS.StateID
						AND PL.CityID = ULS.CityID
					WHERE PL.PostingID = PRD.PostingID
					FOR JSON AUTO				
				), '[]')) as locations
			FROM dbo.vw_postings_raw_data_for_search_lists AS PRD
				LEFT JOIN dbo.User_SavedPostings AS SP WITH(NOLOCK) ON PRD.postingID = SP.PostingID
					AND SP.UserID = @UserIDThatSearches
			WHERE (PRD.PostingTypeID = 1
					AND PRD.PostingActive = 1
					AND PRD.PostingCensored = 0
					AND PRD.PostingUserActive = 1
					AND PRD.PostingUserCensored = 0			
				)
				AND PRD.PostedByUserID = @UserID
				AND SP.PostingID IS NULL
			ORDER BY PRD.PostingID DESC
			FOR JSON PATH, ROOT('postings'), INCLUDE_NULL_VALUES
		),'{"postings":[]}') AS jsonString;

	END; ELSE IF (@UserIDThatSearches IS NOT NULL AND @BelowPostingID IS NOT NULL) BEGIN

		SELECT ISNULL((
			SELECT TOP 20 CAST(PRD.PostingID AS VARCHAR) AS postingId, PRD.PostingTitle AS postingTitle, PRD.PostingMessage AS postingMessage
				, dbo.fnha_ui_how_long_since_posting(PRD.PostDateTime, @LanguageID) AS postedOn
				, PRD.Price AS price, PRD.CurrencySymbol AS currencySymbol, PRD.CurrencyAbbreviation AS currencyAbbreviation
				, @MediaURL + PRD.Avatar AS avatar, CAST(PRD.PostedByUserID AS VARCHAR) AS postedByUserId, PRD.[Name] AS name
				, (ISNULL((
					SELECT @MediaURL + I.[Image] AS [image]
					FROM dbo.Postings_AttachedImages AS AI
					INNER JOIN dbo.Images AS I ON AI.ImageId = I.ImageId
					WHERE AI.PostingID = PRD.PostingID
					FOR JSON AUTO
				), '[]')) AS images
				, (ISNULL((
					SELECT ULS.FullCityName_State_Country AS location
					FROM dbo.Postings_Locations AS PL
					INNER JOIN dbo.UserLocationsSearch  AS ULS ON PL.CountryID = ULS.CountryID
						AND PL.StateID = ULS.StateID
						AND PL.CityID = ULS.CityID
					WHERE PL.PostingID = PRD.PostingID
					FOR JSON AUTO				
				), '[]')) as locations
			FROM dbo.vw_postings_raw_data_for_search_lists AS PRD
				LEFT JOIN dbo.User_SavedPostings AS SP WITH(NOLOCK) ON PRD.postingID = SP.PostingID 
					AND SP.UserID = @UserIDThatSearches
			WHERE (PRD.PostingTypeID = 1
					AND PRD.PostingActive = 1
					AND PRD.PostingCensored = 0
					AND PRD.PostingUserActive = 1
					AND PRD.PostingUserCensored = 0			
				)
				AND PRD.PostedByUserID = @UserID
				AND PRD.PostingID < @BelowPostingID
				AND SP.PostingID IS NULL
			ORDER BY PRD.PostingID DESC
			FOR JSON PATH, ROOT('postings'), INCLUDE_NULL_VALUES
		),'{"postings":[]}') AS jsonString;

	END; ELSE IF (@UserIDThatSearches IS NULL AND @BelowPostingID IS NULL) BEGIN

		SELECT ISNULL((
			SELECT TOP 20 CAST(PRD.PostingID AS VARCHAR) AS postingId, PostingTitle AS postingTitle, PostingMessage AS postingMessage
				, dbo.fnha_ui_how_long_since_posting(PostDateTime, @LanguageID) AS postedOn
				, Price AS price, CurrencySymbol AS currencySymbol, CurrencyAbbreviation AS currencyAbbreviation
				, @MediaURL + Avatar AS avatar, CAST(PostedByUserID AS VARCHAR) AS postedByUserId, [Name] AS name
				, (ISNULL((
					SELECT @MediaURL + I.[Image] AS [image]
					FROM dbo.Postings_AttachedImages AS AI
					INNER JOIN dbo.Images AS I ON AI.ImageId = I.ImageId
					WHERE AI.PostingID = PRD.PostingID
					FOR JSON AUTO
				), '[]')) AS images
				, (ISNULL((
					SELECT ULS.FullCityName_State_Country AS location
					FROM dbo.Postings_Locations AS PL
					INNER JOIN dbo.UserLocationsSearch  AS ULS ON PL.CountryID = ULS.CountryID
						AND PL.StateID = ULS.StateID
						AND PL.CityID = ULS.CityID
					WHERE PL.PostingID = PRD.PostingID
					FOR JSON AUTO				
				), '[]')) as locations
			FROM dbo.vw_postings_raw_data_for_search_lists AS PRD
			WHERE (PRD.PostingTypeID = 1
					AND PRD.PostingActive = 1
					AND PRD.PostingCensored = 0
					AND PRD.PostingUserActive = 1
					AND PRD.PostingUserCensored = 0			
				)
				AND PostedByUserID = @UserID
			ORDER BY PRD.PostingID DESC
			FOR JSON PATH, ROOT('postings'), INCLUDE_NULL_VALUES
		), '{"postings":[]}') AS jsonString;

	END; ELSE IF (@UserIDThatSearches IS NULL AND @BelowPostingID IS NOT NULL) BEGIN

		SELECT ISNULL((
			SELECT TOP 20 CAST(PRD.PostingID AS VARCHAR) AS postingId, PostingTitle AS postingTitle, PostingMessage AS postingMessage
				, dbo.fnha_ui_how_long_since_posting(PostDateTime, @LanguageID) AS postedOn
				, Price AS price, CurrencySymbol AS currencySymbol, CurrencyAbbreviation AS currencyAbbreviation
				, @MediaURL + Avatar AS avatar, CAST(PostedByUserID AS VARCHAR) AS postedByUserId, [Name] AS name
				, (ISNULL((
					SELECT @MediaURL + I.[Image] AS [image]
					FROM dbo.Postings_AttachedImages AS AI
					INNER JOIN dbo.Images AS I ON AI.ImageId = I.ImageId
					WHERE AI.PostingID = PRD.PostingID
					FOR JSON AUTO
				), '[]')) AS images
				, (ISNULL((
					SELECT ULS.FullCityName_State_Country AS location
					FROM dbo.Postings_Locations AS PL
					INNER JOIN dbo.UserLocationsSearch  AS ULS ON PL.CountryID = ULS.CountryID
						AND PL.StateID = ULS.StateID
						AND PL.CityID = ULS.CityID
					WHERE PL.PostingID = PRD.PostingID
					FOR JSON AUTO				
				), '[]')) as locations
			FROM dbo.vw_postings_raw_data_for_search_lists AS PRD
			WHERE (PRD.PostingTypeID = 1
					AND PRD.PostingActive = 1
					AND PRD.PostingCensored = 0
					AND PRD.PostingUserActive = 1
					AND PRD.PostingUserCensored = 0			
				)
				AND PostedByUserID = @UserID
				AND PostingID < @BelowPostingID
			ORDER BY PRD.PostingID DESC
			FOR JSON PATH, ROOT('postings'), INCLUDE_NULL_VALUES
		), '{"postings":[]}') AS jsonString;

	END; ELSE BEGIN
		RAISERROR(N'Invalid request', 16, 1);
	END;
END; ELSE BEGIN
	RAISERROR(N'Bad attempt to obtain use data recorded', 16, 1);
END;


GO
/****** Object:  StoredProcedure [dbo].[Postings_Get_BasedOnSearchWords]    Script Date: 28/02/2021 08:12:39 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [CategoriesSearch].[Postings_Get_BasedOnCategories](
	@IPAddress DECIMAL(38, 0),
	@IpAddressProtocol TINYINT,
	@ChildCategoryId INT,
	@LanguageID INT,
	@BelowPostingID BIGINT = NULL
)
AS


DECLARE @TopCountryID INT
	, @TopStateID INT
	, @TopCityID INT
	, @VisitorSearchListID BIGINT
	, @PublicSearchListID BIGINT
	, @MediaURL VARCHAR(200) = dbo.fn_Get_Media_URL();


EXEC CategoriesSearch.ETL_PublicSearch_PostingsList_UpdatePostingsList
	@IPAddress = @IPAddress
	, @IpAddressProtocol = @IpAddressProtocol
	, @ChildCategoryID = @ChildCategoryId
	, @PublicSearchListID = @PublicSearchListID OUTPUT;




IF (@BelowPostingID IS NULL) BEGIN

	SELECT ISNULL((
			SELECT TOP 20 CAST(VP.PostingID AS NVARCHAR) AS postingId, VP.PostingTitle AS postingTitle, VP.PostingMessage AS postingMessage
				, dbo.fnha_ui_how_long_since_posting(VP.PostDateTime, @LanguageID) AS postedOn
				, VP.Price AS price, VP.CurrencySymbol AS currencySymbol, VP.CurrencyAbbreviation AS currencyAbbreviation
				, @MediaURL + VP.Avatar AS avatar, CAST(VP.PostedByUserID AS NVARCHAR) AS postedByUserID, VP.[Name] AS [name], VP.AttachedImagesCount AS attachedImagesCount
				, (ISNULL((
					SELECT @MediaURL + I.[Image] AS [image]
					FROM dbo.Postings_AttachedImages AS AI
					INNER JOIN dbo.Images AS I ON AI.ImageId = I.ImageId
					WHERE AI.PostingID = VP.PostingID
					FOR JSON PATH
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
				, VP.UserPublicKey AS userPublicKey
			FROM CategoriesSearch.PublicSearchLists_ChildCategories_Postings AS PSLP 
			INNER JOIN dbo.vw_postings_raw_data_for_search_lists AS VP ON PSLP.PostingID = VP.PostingID
			WHERE PSLP.PublicSearchLists_ChildCategories_ID = @PublicSearchListID
				AND (VP.PostingTypeID = 1
					AND VP.PostingActive = 1
					AND VP.PostingCensored = 0
					AND VP.PostingUserActive = 1
					AND VP.PostingUserCensored = 0
				)
			ORDER BY PSLP.PostingID DESC
			FOR JSON PATH, ROOT('postings'), INCLUDE_NULL_VALUES
	), '{"postings":[]}') AS jsonString;
		
END; ELSE IF(@BelowPostingID IS NOT NULL) BEGIN

	SELECT ISNULL((
			SELECT TOP 20 CAST(VP.PostingID AS NVARCHAR) AS postingId, VP.PostingTitle AS postingTitle, VP.PostingMessage AS postingMessage
				, dbo.fnha_ui_how_long_since_posting(VP.PostDateTime, @LanguageID) AS postedOn
				, VP.Price AS price, VP.CurrencySymbol AS currencySymbol, VP.CurrencyAbbreviation AS currencyAbbreviation
				, @MediaURL + VP.Avatar AS avatar, CAST(VP.PostedByUserID AS NVARCHAR) AS postedByUserID, VP.[Name] AS [name], VP.AttachedImagesCount AS attachedImagesCount
				, (ISNULL((
					SELECT @MediaURL + I.[Image] AS [image]
					FROM dbo.Postings_AttachedImages AS AI
					INNER JOIN dbo.Images AS I ON AI.ImageId = I.ImageId
					WHERE AI.PostingID = VP.PostingID
					FOR JSON PATH
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
				, VP.UserPublicKey AS userPublicKey
			FROM CategoriesSearch.PublicSearchLists_ChildCategories_Postings AS PSLP 
			INNER JOIN dbo.vw_postings_raw_data_for_search_lists AS VP ON PSLP.PostingID = VP.PostingID
			WHERE PSLP.PublicSearchLists_ChildCategories_ID = @PublicSearchListID
				AND (VP.PostingTypeID = 1
					AND VP.PostingActive = 1
					AND VP.PostingCensored = 0
					AND VP.PostingUserActive = 1
					AND VP.PostingUserCensored = 0
				)
			ORDER BY PSLP.PostingID DESC
			FOR JSON PATH, ROOT('postings'), INCLUDE_NULL_VALUES
	), '{"postings":[]}') AS jsonString;

END;





GO



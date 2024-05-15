USE ReadWrite_Prod;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE [dbo].[Postings_Get_BasedOnSearchWords](
	@IPAddress DECIMAL(38, 0),
	@IpAddressProtocol TINYINT,
	@Words NVARCHAR(100),
	@LanguageID INT,
	@BelowPostingID BIGINT = NULL
)
AS


DECLARE @TopCountryID INT
	, @TopStateID INT
	, @TopCityID INT
	, @VisitorSearchListID BIGINT
	, @PublicSearchListID BIGINT
	, @SearchWords [dbo].[SearchWordsIDs]
	, @MediaURL VARCHAR(200) = dbo.fn_Get_Media_URL();

DECLARE @WordsTable TABLE (
	Word NVARCHAR(100)
	, SearchWordID BIGINT
);



INSERT INTO @WordsTable(Word)
SELECT DISTINCT LOWER(dbo.fn_StripNonAlphaNumericCharacters(CAST(VALUE AS NVARCHAR(100))))
FROM STRING_SPLIT(@Words, ' ');

INSERT INTO dbo.SearchWords(Word)
SELECT WT.Word
FROM @WordsTable AS WT
LEFT JOIN dbo.SearchWords AS SW WITH(NOLOCK) ON WT.Word = SW.Word
WHERE SW.SearchWordID IS NULL;

UPDATE WT
SET SearchWordID = SW.SearchWordID
	OUTPUT inserted.SearchWordID INTO @SearchWords(SearchwordID)
FROM @WordsTable AS WT
INNER JOIN dbo.SearchWords AS SW ON WT.Word = SW.Word;



EXEC dbo.ETL_PublicSearch_PostingsList_UpdatePostingsList
	@IPAddress = @IPAddress
	, @IpAddressProtocol = @IpAddressProtocol
	, @LanguageID = @LanguageID
	, @SearchWords = @SearchWords
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
			FROM dbo.PublicSearchLists_Postings AS PSLP 
			INNER JOIN dbo.vw_postings_raw_data_for_search_lists AS VP ON PSLP.PostingID = VP.PostingID
			WHERE PSLP.PublicSearchListID = @PublicSearchListID
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
			FROM dbo.PublicSearchLists_Postings AS PSLP 
			INNER JOIN dbo.vw_postings_raw_data_for_search_lists AS VP ON PSLP.PostingID = VP.PostingID
			WHERE PSLP.PublicSearchListID = @PublicSearchListID
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
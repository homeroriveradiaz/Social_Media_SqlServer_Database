USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Locations_GetLocationsUsedInPreviousPosting]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'Postings_Get_LocationsUsedInPreviousPosting', N'P') IS NULL BEGIN
	EXEC('CREATE PROC dbo.Postings_Get_LocationsUsedInPreviousPosting AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[Postings_Get_LocationsUsedInPreviousPosting](
	@UserID BIGINT
)
AS


DECLARE @LastPostingID BIGINT;


SELECT @LastPostingID = MAX(PostingID)
FROM dbo.Postings WITH(NOLOCK)
WHERE PostedByUserID = @UserID
	AND PostingTypeID = 1;
		


SELECT ISNULL((
	SELECT CAST(PL.CountryID AS VARCHAR) + '_' + CAST(PL.StateID AS VARCHAR) + '_' + CAST(PL.CityID AS VARCHAR) AS locationCode
		, CASE
			WHEN PL.StateID = -1 THEN 'all ' + C.Country
			WHEN PL.CityID = -1 THEN 'all cities in ' + S.StateAbbreviation + ', ' + C.Country
			ELSE CT.City + ', ' + S.StateAbbreviation + ', ' + C.CountryAbbreviation
		END AS location
	FROM dbo.Postings_Locations AS PL WITH(NOLOCK)
	LEFT JOIN dbo.Location_Countries AS C WITH(NOLOCK) ON PL.CountryID = C.CountryID
	LEFT JOIN dbo.Location_States AS S WITH(NOLOCK) ON PL.StateID = S.StateID
	LEFT JOIN dbo.Location_Cities AS CT WITH(NOLOCK) ON PL.CityID = CT.CityID
	WHERE PL.PostingID = @LastPostingID
	FOR JSON PATH, ROOT('locationsPreviousPosting'), INCLUDE_NULL_VALUES
), '{"locationsPreviousPosting":[]}') AS jsonString;



GO
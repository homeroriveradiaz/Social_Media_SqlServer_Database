USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Location_GetUsersLocations]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'SuiGenerisSearchCriteria_Get_Locations', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.SuiGenerisSearchCriteria_Get_Locations AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[SuiGenerisSearchCriteria_Get_Locations](
	@UserID BIGINT
	, @LanguageID INT
)
AS


SELECT ISNULL((
	SELECT ULF.UserRowID AS searchLocationId
		, CASE WHEN @LanguageID = 1 THEN --English
				CASE WHEN ST.StateID IS NULL THEN 'all ' + CO.Country
					WHEN CI.CityID IS NULL THEN 'all ' + ST.[State] + ', ' + CO.Country
					ELSE CI.City + ', ' + ST.StateAbbreviation + ', ' + CO.CountryAbbreviation 
				END 
			WHEN @LanguageID = 2 THEN --Spanish
				CASE WHEN ST.StateID IS NULL THEN 'todo ' + CO.Country
					WHEN CI.CityID IS NULL THEN 'todo ' + ST.[State] + ', ' + CO.Country
					ELSE CI.City + ', ' + ST.StateAbbreviation + ', ' + CO.CountryAbbreviation 
				END 
		END AS location
	FROM dbo.User_LocationsFollowed AS ULF WITH(NOLOCK)
	LEFT JOIN dbo.Location_Countries AS CO WITH(NOLOCK) ON ULF.CountryId = CO.CountryID
	LEFT JOIN dbo.Location_States AS ST WITH(NOLOCK) ON ULF.StateID = ST.StateID
	LEFT JOIN dbo.Location_Cities AS CI WITH(NOLOCK) ON ULF.CityId = CI.CityID
	WHERE ULF.UserID = @UserID
	ORDER BY CO.CountryAbbreviation
		, ISNULL(ST.StateAbbreviation, '-1')
		, ISNULL(CI.City, '-1')
	FOR JSON PATH, ROOT('searchLocations')
), '{"searchLocations":[]}') AS jsonString;


GO


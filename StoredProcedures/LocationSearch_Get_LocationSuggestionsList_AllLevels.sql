USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[GET_TopLocations_ForUserSearch_Subscriber]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID(N'LocationSearch_Get_LocationSuggestionsList_AllLevels', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.LocationSearch_Get_LocationSuggestionsList_AllLevels AS SELECT 1;');
END;
GO


ALTER PROC [dbo].[LocationSearch_Get_LocationSuggestionsList_AllLevels](
	@Location NVARCHAR(100)
)
AS

IF (LEN(@Location) >= 4) BEGIN
SELECT ISNULL((
	SELECT TOP 8 FullCityName_State_Country AS location
	FROM dbo.UserLocationsSearch WITH(NOLOCK)
	WHERE FullCityName_State_Country LIKE @Location + '%'
	ORDER BY location ASC
	FOR JSON PATH, ROOT('locations')
), N'{"locations":[]}') AS jsonString;

END; ELSE BEGIN

	SELECT N'{"locations":[]}' AS jsonString;

END;



GO
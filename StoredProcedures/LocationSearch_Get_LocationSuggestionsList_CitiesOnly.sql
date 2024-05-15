USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[GET_TopLocations_ForUSerSearch]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'LocationSearch_Get_LocationSuggestionsList_CitiesOnly', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.LocationSearch_Get_LocationSuggestionsList_CitiesOnly AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[LocationSearch_Get_LocationSuggestionsList_CitiesOnly](
	@LocationHint NVARCHAR(100)
)
AS



IF (LEN(@LocationHint) >= 2) BEGIN

	SELECT ISNULL((
		SELECT TOP 8 FullCityName_State_Country AS location
		FROM Location_Cities WITH(NOLOCK)
		WHERE FullCityName_State_Country LIKE '%' + @LocationHint + '%'
		ORDER BY FullCityName_State_Country
		FOR JSON PATH, ROOT('locations')
	), N'{"locations":[]}') AS jsonString;

END; ELSE BEGIN

	SELECT N'{"locations":[]}' AS jsonString;

END;




GO
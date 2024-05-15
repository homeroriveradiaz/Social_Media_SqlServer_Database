USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[GET_UserLocationSearch_BestMatch_OnlyCities]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO


IF OBJECT_ID(N'LocationSearch_Get_BestMatch_OnlyCityLevel', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.LocationSearch_Get_BestMatch_OnlyCityLevel AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[LocationSearch_Get_BestMatch_OnlyCityLevel]
	@Locationstring NVARCHAR(100)
AS


DECLARE @MinRowID INT = NULL,
	@Found BIT = 0,
	@Location NVARCHAR(100) = NULL,
	@LocationNumber NVARCHAR(100) = NULL;


SELECT @MinRowID = MIN(ULS.rowID)
FROM dbo.UserLocationsSearch AS ULS WITH(NOLOCK)
INNER JOIN dbo.Location_Cities AS C WITH(NOLOCK) ON ULS.CityID = C.CityID 
	AND ULS.StateID = C.StateID
WHERE C.FullCityName_State_Country LIKE '%' + @Locationstring + '%'
	AND ULS.StateID <> -1
	AND ULS.CityID <> -1;


SELECT @Found = 1
	, @Location = FullCityName_State_Country
	, @LocationNumber = CAST(CountryID AS VARCHAR) + '_' + CAST(StateID AS VARCHAR) + '_' + CAST(CityID AS VARCHAR)
FROM dbo.UserLocationsSearch WITH(NOLOCK)
WHERE rowID = @MinRowID;


SELECT (
	SELECT @Found AS found
		, @Location AS location
		, @LocationNumber AS locationNumber
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
) AS jsonString;


GO
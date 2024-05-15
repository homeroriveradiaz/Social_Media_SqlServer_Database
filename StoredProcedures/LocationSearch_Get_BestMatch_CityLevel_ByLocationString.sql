USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[GET_UserLocationSearch_BestMatch_OnlyCities]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'LocationSearch_Get_BestMatch_CityLevel_ByLocationString', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.LocationSearch_Get_BestMatch_CityLevel_ByLocationString AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[LocationSearch_Get_BestMatch_CityLevel_ByLocationString](
	@Locationstring NVARCHAR(100)
	, @CountryID INT OUTPUT
	, @StateID INT OUTPUT
	, @CityID INT OUTPUT
	, @ExactLocationstring NVARCHAR(100) OUTPUT
)
AS


DECLARE @MinRowID INT;

SELECT @MinRowID = MIN(ULS.rowID)
FROM dbo.UserLocationsSearch AS ULS WITH(NOLOCK)
INNER JOIN dbo.Location_Cities AS C WITH(NOLOCK) ON ULS.CityID = C.CityID 
	AND ULS.StateID = C.StateID
WHERE C.FullCityName_State_Country LIKE @Locationstring + '%'
	AND ULS.StateID <> -1
	AND ULS.CityID <> -1;


IF (@MinRowID IS NOT NULL) BEGIN
	
	SELECT @CountryID = CountryID
		, @StateID = StateID
		, @CityID = CityID
		, @ExactLocationstring = FullCityName_State_Country
	FROM dbo.UserLocationsSearch WITH(NOLOCK)
	WHERE rowID = @MinRowID;

END; ELSE BEGIN
	
	SELECT @CountryID = NULL
		, @StateID = NULL
		, @CityID = NULL
		, @ExactLocationstring = NULL;

END;

RETURN;

GO
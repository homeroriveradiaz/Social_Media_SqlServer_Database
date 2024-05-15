USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[GET_UserLocationSearch_BestMatch]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO


IF OBJECT_ID(N'LocationSearch_Get_BestMatch_AllLevels', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.LocationSearch_Get_BestMatch_AllLevels AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[LocationSearch_Get_BestMatch_AllLevels](
	@Locationstring NVARCHAR(100)
	, @CountryID INT OUTPUT
	, @StateID INT OUTPUT
	, @CityID INT OUTPUT
	, @ExactLocationstring NVARCHAR(100) OUTPUT
)
AS


DECLARE @MinRowID INT;

SELECT @MinRowID = MIN(rowID)
FROM dbo.UserLocationsSearch WITH(NOLOCK)
WHERE FullCityName_State_Country LIKE '%' + @Locationstring + '%';


IF (@MinRowID IS NULL) BEGIN

	SELECT @CountryID = NULL
		, @StateID = NULL
		, @CityID = NULL
		, @ExactLocationstring = NULL;

END; ELSE BEGIN

	SELECT @CountryID = CountryID
		, @StateID = StateID
		, @CityID = CityID
		, @ExactLocationstring = FullCityName_State_Country
	FROM dbo.UserLocationsSearch WITH(NOLOCK)
	WHERE rowID = @MinRowID;

END;

RETURN;

GO



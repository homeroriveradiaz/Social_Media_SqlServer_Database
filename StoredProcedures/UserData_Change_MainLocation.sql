USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Profile_Remove_SimpleAsset]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO


IF OBJECT_ID(N'dbo.UserData_Change_MainLocation', N'P') IS NULL BEGIN
	EXEC('CREATE PROC dbo.UserData_Change_MainLocation AS SELECT 1;');
END;
GO

ALTER PROC dbo.UserData_Change_MainLocation(
	@UserID BIGINT
	, @Locationstring NVARCHAR(100)
) AS


DECLARE @CityID INT
	, @StateID INT
	, @CountryID INT
	, @ExactLocationstring NVARCHAR(100)
	, @Found BIT = 0;


EXEC [dbo].[LocationSearch_Get_BestMatch_CityLevel_ByLocationString]
	@Locationstring = @Locationstring
	, @CountryID = @CountryID OUTPUT
	, @StateID = @StateID OUTPUT
	, @CityID = @CityID OUTPUT
	, @ExactLocationstring = @ExactLocationstring OUTPUT;


IF (@CountryID IS NOT NULL) BEGIN
	
	UPDATE dbo.Users 
	SET BaseCityID = @CityID
		, BaseStateID = @StateID
		, BaseCountryID = @CountryID
	WHERE UserID = @UserID
		AND Active = 1
		AND Censored = 0;

	SET @Found = 1;
	
END;


SELECT (
	SELECT @Found AS found
		, ISNULL(@ExactLocationstring, N'') AS location
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
) AS jsonString;


GO
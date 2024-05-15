USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Get_CitystateCountry_FromIP]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'LocationSearch_Get_CityStateCountryFromIP', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.LocationSearch_Get_CityStateCountryFromIP AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[LocationSearch_Get_CityStateCountryFromIP](
	@IpAddress DECIMAL(38, 0)
	, @IPAddressVersionID TINYINT
)
AS


DECLARE @CountryID INT
	, @StateID INT
	, @CityID INT
	, @IPAddressVersionsStr VARCHAR(10) = CASE @IPAddressVersionID WHEN 1 THEN 'v4' WHEN 2 THEN 'v6' END;



EXEC dbo.LocationSearch_Get_LocationBasedOnIP
	@IpAddress = @IpAddress
	, @IPAddressVersion = @IPAddressVersionsStr
	, @CountryID = @CountryID OUTPUT
	, @StateID = @StateID OUTPUT
	, @CityID = @CityId OUTPUT;



SELECT (
	SELECT ci.City + ', ' + s.StateAbbreviation + ', ' + co.CountryAbbreviation AS location
	FROM dbo.Location_Countries AS CO WITH(NOLOCK)
	INNER JOIN dbo.Location_States AS S WITH(NOLOCK) ON CO.CountryID = S.CountryID
	INNER JOIN dbo.Location_Cities AS CI WITH(NOLOCK) ON CI.StateID = S.StateID
	WHERE CO.CountryID = @CountryID
		AND S.StateID = @StateID
		AND CI.CityID = @CityId
	FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
) AS jsonString;



GO
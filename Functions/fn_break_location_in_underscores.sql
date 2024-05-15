/****** Object:  UserDefinedFunction [dbo].[fn_break_image_string_in_brackets]    Script Date: 11/03/2017 1:57:00 p. m. ******/
USE ReadWrite_Prod;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/***************************************************************************
LOCATIONS ARE SENT TO THE DATABASE IN THE FORM:
	COUNTRYID_STATEID_CITYID

	E.G. [134_34_651][1_2_3][45_67_89]

	WE NEED TO RETURN THEM IN 3 CONVENIENT COLUMNS AS IN:
	
	CountryID	StateID	 CityID
	--------------------------------
	134			34		651
	1			2		3
	45			67		89

	WE FIRST PUT THE STRING IN ANOTHER FUNCTION TO FIRST STACK
	THEM UP, AND THEN WE SPLIT

***************************************************************************/
CREATE FUNCTION dbo.fn_break_location_in_underscores(
	@LocationsString NVARCHAR(MAX)
)
RETURNS @Locations TABLE(CountryID INT, StateID INT, CityID INT)
AS
BEGIN
	


	DECLARE @StringLocationsTable TABLE (
		Locations NVARCHAR(30)
		, CountryID NVARCHAR(30)
		, StateID NVARCHAR(30)
		, CityID NVARCHAR(30)
	);


	INSERT INTO @StringLocationsTable(Locations)
	SELECT Items
	FROM dbo.fn_break_string_in_brackets(@LocationsString);

	
	UPDATE @StringLocationsTable
	SET CountryID = SUBSTRING(Locations, 1, PATINDEX('%[_]%', Locations) -1)
		, StateID = SUBSTRING(Locations, PATINDEX('%[_]%', Locations) + 1, LEN(Locations))
		, CityID = REVERSE(SUBSTRING(REVERSE(Locations), 1, PATINDEX('%[_]%', REVERSE(Locations)) - 1));


	UPDATE @StringLocationsTable
	SET StateID = SUBSTRING(StateID, 1, PATINDEX('%[_]%', StateID) - 1);


	INSERT INTO @Locations(CountryID, StateID, CityID)
	SELECT CAST(CountryID AS INT), CAST(StateID AS INT), CAST(CityID AS INT)
	FROM @StringLocationsTable;


	RETURN;


END
GO








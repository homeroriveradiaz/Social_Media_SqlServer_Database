
IF OBJECT_ID(N'dbo.ETL_IPUpdate_Locations_CreateTempTable', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.ETL_IPUpdate_Locations_CreateTempTable AS SELECT 1;');
END;
GO


ALTER PROC dbo.ETL_IPUpdate_Locations_CreateTempTable
AS

CREATE TABLE ##TL(
	GeoIP2 INT
	, CountryAbbreviation NVARCHAR(10)
	, Country NVARCHAR(100)
	, StateAbbreviation NVARCHAR(10)
	, [State] NVARCHAR(100)
	, City NVARCHAR(100)
);


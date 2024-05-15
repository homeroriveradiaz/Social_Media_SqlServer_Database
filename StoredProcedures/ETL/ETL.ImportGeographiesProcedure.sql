CREATE OR ALTER PROC ETL.ImportGeographiesProcedure(
	@Geographies ETL.ImportGeographiesTableType READONLY
) AS 


INSERT INTO ETL.ImportGeographies(
	geoname_id 
	, country_iso_code 
	, country_name 
	, subdivision_1_iso_code 
	, subdivision_1_name 
	, city_name 
)
SELECT 	geoname_id 
	, country_iso_code 
	, country_name 
	, subdivision_1_iso_code 
	, subdivision_1_name 
	, city_name 
FROM @Geographies;


GO

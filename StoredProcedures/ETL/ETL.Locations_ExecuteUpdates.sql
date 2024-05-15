CREATE OR ALTER PROC ETL.Locations_ExecuteUpdates
AS


UPDATE ETL.ImportGeographies SET country_name = replace(country_name, 'é', 'e'), subdivision_1_name = REPLACE(subdivision_1_name, 'Á', 'A'), city_name = REPLACE(subdivision_1_name, 'Á', 'A') WHERE country_iso_code = 'MX';
UPDATE ETL.ImportGeographies SET subdivision_1_name = REPLACE(subdivision_1_name, 'É', 'E'), city_name = REPLACE(subdivision_1_name, 'É', 'E') WHERE country_iso_code = 'MX';
UPDATE ETL.ImportGeographies SET subdivision_1_name = REPLACE(subdivision_1_name, 'Í', 'I'), city_name = REPLACE(subdivision_1_name, 'Í', 'I') WHERE country_iso_code = 'MX';
UPDATE ETL.ImportGeographies SET subdivision_1_name = REPLACE(subdivision_1_name, 'Ó', 'O'), city_name = REPLACE(subdivision_1_name, 'Ó', 'O') WHERE country_iso_code = 'MX';
UPDATE ETL.ImportGeographies SET subdivision_1_name = REPLACE(subdivision_1_name, 'Ú', 'U'), city_name = REPLACE(subdivision_1_name, 'Ú', 'U') WHERE country_iso_code = 'MX';
UPDATE ETL.ImportGeographies SET subdivision_1_name = REPLACE(subdivision_1_name, 'á', 'a'), city_name = REPLACE(subdivision_1_name, 'á', 'a') WHERE country_iso_code = 'MX';
UPDATE ETL.ImportGeographies SET subdivision_1_name = REPLACE(subdivision_1_name, 'é', 'e'), city_name = REPLACE(subdivision_1_name, 'é', 'e') WHERE country_iso_code = 'MX';
UPDATE ETL.ImportGeographies SET subdivision_1_name = REPLACE(subdivision_1_name, 'í', 'i'), city_name = REPLACE(subdivision_1_name, 'í', 'i') WHERE country_iso_code = 'MX';
UPDATE ETL.ImportGeographies SET subdivision_1_name = REPLACE(subdivision_1_name, 'ó', 'o'), city_name = REPLACE(subdivision_1_name, 'ó', 'o') WHERE country_iso_code = 'MX';
UPDATE ETL.ImportGeographies SET subdivision_1_name = REPLACE(subdivision_1_name, 'ú', 'u'), city_name = REPLACE(subdivision_1_name, 'ú', 'u') WHERE country_iso_code = 'MX';


UPDATE ETL.ImportGeographies
SET subdivision_1_name = CASE subdivision_1_name
	WHEN 'Coahuila de Zaragoza' THEN 'Coahuila'
	WHEN 'Mexico' THEN 'Estado de Mexico'
	WHEN 'Michoacan de Ocampo' THEN 'Michoacan'
	WHEN 'Queretaro de Arteaga' THEN 'Queretaro'
	WHEN 'Veracruz-Llave' THEN 'Veracruz'
	ELSE subdivision_1_name END
WHERE country_iso_code = 'MX';


WITH TlCo AS (
    SELECT DISTINCT country_iso_code AS CountryAbbreviation
		, country_name AS Country
    FROM ETL.ImportGeographies
)
MERGE INTO [dbo].[Location_Countries] AS T
USING TlCo AS S
ON T.Country = S.Country
WHEN NOT MATCHED THEN
	INSERT([Country], [CountryAbbreviation])
	VALUES(S.Country, S.CountryAbbreviation);


WITH TlSt AS (
    SELECT DISTINCT T.subdivision_1_iso_code AS StateAbbreviation, T.subdivision_1_name AS [State], C.CountryID
    FROM ETL.ImportGeographies AS T
    INNER JOIN [dbo].[Location_Countries] AS C ON T.country_iso_code = C.CountryAbbreviation
)
MERGE INTO [dbo].[Location_States] AS T
USING TlSt AS S
ON T.[StateAbbreviation] = S.StateAbbreviation
	AND T.[State] = S.[State]
	AND T.CountryID = S.CountryID
WHEN NOT MATCHED THEN
	INSERT(CountryID, [State], StateAbbreviation, StateAbbreviationApplicable)
	VALUES(S.CountryID, S.[State], S.StateAbbreviation, 1);

     
WITH TLCt AS (
	SELECT LEFT(T.city_name, 100) AS City
		, LS.StateID
		, CAST(T.geoname_id AS int) AS GeoIP2Id
		, LEFT(CASE WHEN T.city_name <> '' THEN T.city_name + ', ' ELSE '' END + CASE WHEN LS.[State] <> '' THEN LS.[State] + ', ' ELSE '' END + C.Country, 100) AS FullCityName_State_Country
	FROM ETL.ImportGeographies AS T
	INNER JOIN [dbo].[Location_States] AS LS ON T.subdivision_1_name = LS.[state]
	INNER JOIN [dbo].[Location_Countries] AS C ON LS.CountryID = C.CountryID
		AND T.country_iso_code = C.CountryAbbreviation
)
MERGE INTO dbo.Location_Cities AS T
USING TLCt AS S ON T.City = S.City AND T.StateID = S.StateID
WHEN NOT MATCHED THEN
	INSERT([StateID], [City], [FullCityName_State_Country], GeoIP2Id)
	VALUES(S.StateID, S.City, S.FullCityName_State_Country, S.GeoIP2Id);


WITH ULS AS (
	SELECT CO.CountryID, S.StateID, C.CityID, 
		CASE WHEN C.City <> '' THEN C.City + ', ' ELSE '' END 
		+ CASE WHEN S.StateAbbreviation <> '' THEN S.StateAbbreviation + ', ' ELSE '' END
		+ CO.CountryAbbreviation AS FullCityName_State_Country
	FROM dbo.Location_Cities AS C
	INNER JOIN dbo.Location_States AS S ON C.StateID = S.StateID
	INNER JOIN dbo.Location_Countries AS CO ON S.CountryID = CO.CountryID
)
MERGE INTO [dbo].[UserLocationsSearch] AS T
USING ULS AS S
ON T.CountryID = S.CountryID
	AND T.StateID = S.StateID
	AND T.CityID = S.CityID
WHEN MATCHED AND T.FullCityName_State_Country <> S.FullCityName_State_Country THEN
	UPDATE SET FullCityName_State_Country = S.FullCityName_State_Country
WHEN NOT MATCHED THEN 
	INSERT(FullCityName_State_Country, CountryID, StateID, CityID)
	VALUES(S.FullCityName_State_Country, S.CountryID, S.StateID, S.CityID);




TRUNCATE TABLE ETL.ImportGeographies;

GO
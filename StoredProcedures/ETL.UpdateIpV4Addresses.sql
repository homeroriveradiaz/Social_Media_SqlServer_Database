CREATE OR ALTER PROC ETL.UpdateIpV4Addresses(
	@IPs ETL.TT_IPV4_Staging READONLY
) AS


TRUNCATE TABLE dbo.IPAddress_VS_Location;

INSERT INTO dbo.IPAddress_VS_Location(IPAddressVersionID, FromIP, ToIP, CountryID, StateID, CityID, Latitude, Longitude, ZipCode)
SELECT 1 AS IPAddressVersionID
	, I.iprangestart
	, I.iprangeend
	, LS.CountryID
	, LS.StateID
	, LC.CityID
	, I.latitude
	, I.longitude
	, I.postal_code
FROM @IPs AS I
JOIN dbo.Location_Cities AS LC ON I.geoname_id = LC.GeoIP2Id
JOIN dbo.Location_States AS LS ON LC.StateID = LS.StateID;


WITH NewIPs AS (
	SELECT CityID
		, AVG(Latitude) AS Latitude
		, AVG(Longitude) AS Longitude
	FROM dbo.IPAddress_VS_Location
	GROUP BY CityID
)
MERGE [dbo].[Location_Cities_Latitude_Longitude] AS T
USING NewIPs AS S
ON T.CityID = S.CityID
WHEN MATCHED THEN 
UPDATE SET
	[AvgLatitude] = S.Latitude
    ,[AvgLongitude] = S.Longitude
    ,[AvgLatitudeUpperLimit1] = S.Latitude + 1
    ,[AvgLatitudeLowerLimit1] = S.Latitude - 1
    ,[AvgLongitudeLeftmostLimit1] = S.Longitude - 1
    ,[AvgLongitudeRightmostLimit1] = S.Longitude + 1
    ,[AvgLatitudeUpperLimit2] = S.Latitude + 2
    ,[AvgLatitudeLowerLimit2] = S.Latitude - 2
    ,[AvgLongitudeLeftmostLimit2] = S.Longitude - 2
    ,[AvgLongitudeRightmostLimit2] = S.Longitude + 2
WHEN NOT MATCHED THEN 
INSERT
	([CityID],[AvgLatitude],[AvgLongitude],[AvgLatitudeUpperLimit1]
	,[AvgLatitudeLowerLimit1],[AvgLongitudeLeftmostLimit1],[AvgLongitudeRightmostLimit1],[AvgLatitudeUpperLimit2]
	,[AvgLatitudeLowerLimit2],[AvgLongitudeLeftmostLimit2],[AvgLongitudeRightmostLimit2])
VALUES
	(S.CityID, S.Latitude, S.Longitude, S.Latitude + 1
	, S.Latitude - 1, S.Longitude - 1, S.Longitude + 1, S.Latitude + 2
	, S.Latitude - 2, S.Longitude - 2, S.Longitude + 2);



GO


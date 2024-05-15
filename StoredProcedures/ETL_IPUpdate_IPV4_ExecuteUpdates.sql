
IF OBJECT_ID(N'dbo.ETL_IPUpdate_IPV4_ExecuteUpdates', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.ETL_IPUpdate_IPV4_ExecuteUpdates AS SELECT 1;');
END;
GO

ALTER PROC dbo.ETL_IPUpdate_IPV4_ExecuteUpdates
AS


DECLARE @CountryID INT
	, @StateID INT
	, @CityID INT;


SELECT S.CountryID, S.StateID, C.CityID
	, T.latitude, T.Longitude, T.postal_code AS ZipCode
	, 1 AS IPAddressVersionID, T.IpRangeStart AS FromIP, T.IpRangeEnd AS ToIP
	INTO #BATCHES
FROM ##TIPV4 AS T
INNER JOIN [dbo].[Location_Cities] AS C ON T.geoname_id = C.GeoIP2Id
INNER JOIN [dbo].[Location_States] AS S ON C.StateID = S.StateID;


DELETE IVL
FROM [dbo].[IPAddress_VS_Location] AS IVL
LEFT JOIN (
	SELECT DISTINCT CountryID, StateID, CityID
	FROM #BATCHES
) AS DB ON IVL.CountryID = DB.CountryID
	AND IVL.StateID = DB.StateID
	AND IVL.CityID = DB.CityID
WHERE IVL.CountryID IN (
		SELECT DISTINCT CountryID
		FROM #BATCHES
	)
	AND DB.StateID IS NULL
	AND DB.CityID IS NULL;


WHILE EXISTS(SELECT 1 FROM #BATCHES) BEGIN
	
	SELECT TOP 1 @CountryID = CountryID
		, @StateID = StateID
		, @CityID = CityID
	FROM #BATCHES;

	DELETE [dbo].[IPAddress_VS_Location]
	WHERE CountryID = @CountryID
		AND StateID = @StateID
		AND CityID = @CityID;

	INSERT INTO [dbo].[IPAddress_VS_Location](
		[IPAddressVersionID], [FromIP], [ToIP], [CountryID], [StateID], [CityID], 
		[Latitude], [Longitude], [ZipCode]
	)
	SELECT [IPAddressVersionID], FromIP, ToIP, CountryID, StateID, CityID
		, latitude, Longitude, ZipCode
	FROM #BATCHES
	WHERE CountryID = @CountryID
		AND StateID = @StateID
		AND CityID = @CityID;

	DELETE #BATCHES
	WHERE CountryID = @CountryID
		AND StateID = @StateID
		AND CityID = @CityID;

END;




GO
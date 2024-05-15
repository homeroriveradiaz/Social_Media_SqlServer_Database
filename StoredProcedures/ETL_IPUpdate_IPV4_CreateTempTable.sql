
IF OBJECT_ID(N'dbo.ETL_IPUpdate_IPV4_CreateTempTable', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.ETL_IPUpdate_IPV4_CreateTempTable AS SELECT 1;');
END;
GO


ALTER PROC dbo.ETL_IPUpdate_IPV4_CreateTempTable
AS 

CREATE TABLE ##TIPV4 (
	IpRangeStart BIGINT,
	IpRangeEnd BIGINT,
	geoname_id INT,
	postal_code VARCHAR(15),
	latitude FLOAT,
	longitude FLOAT
);

GO
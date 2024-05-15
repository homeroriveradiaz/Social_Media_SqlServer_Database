CREATE TABLE ETL.IPV4_Staging (
	iprangestart decimal(38, 0)
	, iprangeend decimal(38, 0)
	, geoname_id int null
	, postal_code varchar(15) null
	, latitude float null
	, longitude float null
);
GO

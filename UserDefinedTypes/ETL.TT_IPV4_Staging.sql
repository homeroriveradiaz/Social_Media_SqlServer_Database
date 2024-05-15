CREATE TYPE ETL.TT_IPV4_Staging AS TABLE (
	iprangestart decimal(38, 0)
	, iprangeend decimal(38, 0)
	, geoname_id int null
	, postal_code varchar(15) null
	, latitude float null
	, longitude float null
);
GO
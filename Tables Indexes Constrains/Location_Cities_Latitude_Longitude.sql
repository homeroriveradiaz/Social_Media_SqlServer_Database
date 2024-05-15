USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[Users]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Location_Cities_Latitude_Longitude] (
	LocationCitiesLatLonID BIGINT IDENTITY(-9223372036854775808, 1) NOT NULL
	, CityID INT NOT NULL
	, AvgLatitude FLOAT NOT NULL
	, AvgLongitude FLOAT NOT NULL
	, AvgLatitudeUpperLimit1 FLOAT NOT NULL
	, AvgLatitudeLowerLimit1 FLOAT NOT NULL
	, AvgLongitudeLeftmostLimit1 FLOAT NOT NULL
	, AvgLongitudeRightmostLimit1 FLOAT NOT NULL
	, AvgLatitudeUpperLimit2 FLOAT NOT NULL
	, AvgLatitudeLowerLimit2 FLOAT NOT NULL
	, AvgLongitudeLeftmostLimit2 FLOAT NOT NULL
	, AvgLongitudeRightmostLimit2 FLOAT NOT NULL
);

GO

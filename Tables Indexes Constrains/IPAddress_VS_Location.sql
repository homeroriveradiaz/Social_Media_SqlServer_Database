USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[IPAddress_VS_Location]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IPAddress_VS_Location](
	[IPAddressRangeGeographyID] [bigint] IDENTITY(-9223372036854775808,1) NOT NULL,
	[IPAddressVersionID] [tinyint] NULL,
	[FromIP] [decimal](38, 0) NULL,
	[ToIP] [decimal](38, 0) NULL,
	[CountryID] [int] NULL,
	[StateID] [int] NULL,
	[CityID] [int] NULL,
	[Latitude] FLOAT NULL,
	[Longitude] FLOAT NULL,
	[ZipCode] VARCHAR(15)
) ON [PRIMARY]

GO

CREATE NONCLUSTERED INDEX IX_IPAddressVSLocation_CityID_INCLD_Latitude_Longitude
ON [dbo].[IPAddress_VS_Location] ([CityID]) INCLUDE ([Latitude],[Longitude])
GO


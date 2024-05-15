USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[Location_Cities]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Location_Cities](
	[CityID] [int] IDENTITY(1, 1) PRIMARY KEY,
	[StateID] [int] NULL,
	[City] [nvarchar](100) NULL,
	[FullCityName_State_Country] [nvarchar](100) NULL,
	GeoIP2Id INT NULL

) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Location_Cities] ADD CONSTRAINT FK_LocationState_LocationCities_StateID
FOREIGN KEY (StateID) REFERENCES dbo.Location_States(StateID);

GO
USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[UserLocationsSearch]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserLocationsSearch](
	[rowID] [int] IDENTITY(1,1) NOT NULL,
	[FullCityName_State_Country] [nvarchar](100) NULL,
	[CountryID] [int] NULL,
	[StateID] [int] NULL,
	[CityID] [int] NULL
) ON [PRIMARY]

GO
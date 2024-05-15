USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[User_LocationsFollowed]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[User_LocationsFollowed](
	[UserID] [bigint] NULL,
	[UserRowID] [int] NULL,
	[CountryID] [int] NULL,
	[StateID] [int] NULL,
	[CityID] [int] NULL
) ON [PRIMARY]

GO
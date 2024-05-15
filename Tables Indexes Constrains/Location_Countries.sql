USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[Location_Countries]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Location_Countries](
	[CountryID] [int] IDENTITY(1, 1) PRIMARY KEY,
	[Country] [nvarchar](100) NULL,
	[CountryAbbreviation] [varchar](10) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
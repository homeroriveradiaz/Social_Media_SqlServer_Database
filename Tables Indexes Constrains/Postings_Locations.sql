USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[Postings_Locations]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Postings_Locations](
	[PostingID] [bigint] NULL,
	[CountryID] [int] NULL,
	[StateID] [int] NULL,
	[CityID] [int] NULL,
	[Active] [bit] NULL
) ON [PRIMARY]

GO


CREATE NONCLUSTERED INDEX NCIX_Postings_Locations_PostingID
ON dbo.Postings_Locations(PostingID);
GO
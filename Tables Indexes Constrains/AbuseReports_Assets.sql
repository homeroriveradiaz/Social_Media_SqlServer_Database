USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[AbuseReports_Assets]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AbuseReports_Assets](
	[AbuseReportID] [bigint] NULL,
	[Asset] [nvarchar](500) NULL
) ON [PRIMARY]

GO
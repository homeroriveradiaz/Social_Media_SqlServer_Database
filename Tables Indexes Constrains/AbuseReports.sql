/****** Object:  Table [dbo].[AbuseReports]    Script Date: 27/09/2017 11:53:22 p. m. ******/
USE ReadWrite_Prod;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AbuseReports](
	[AbuseReportID] [bigint] IDENTITY(-9223372036854775808,1) NOT NULL,
	[ObjectID] [tinyint] NULL,
	[IdOfObjectBeingReported] [bigint] NULL,
	[ReportTypeID] [smallint] NULL,
	[ReportingUserID] [bigint] NULL,
	[ReportingUserMessageHint] [nvarchar](500) NULL,
	[ReportedUserID] [bigint] NULL,
	[ReportDate] [smalldatetime] NULL,
	[PostingIDForReportFollowUp] [bigint] NULL,
	[ReportedItemTitle] [nvarchar](100) NULL,
	[ReportedItemQuote] [nvarchar](100) NULL,
	[ReportedItemMessage] [nvarchar](4000) NULL,
	[AssignedToEmployeeID] [bigint] NULL,
	[FirstUpdate] [smalldatetime] NULL,
	[LastUpdate] [smalldatetime] NULL,
	[Active] [bit] NULL
) ON [PRIMARY]

GO
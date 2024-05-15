USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[Postings]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PostingsInThreads](
	[PostingInThreadID] [bigint] IDENTITY(-9223372036854775808,1) NOT NULL,
	[PostingThreadID] [bigint] NULL,
	[PostedByUserID] [bigint] NULL,
	[PostDateTime] [smalldatetime] NULL,
	[PostingMessage] [nvarchar](4000) NULL,
	[FromIPAddress] [bigint] NULL
) ON [PRIMARY]
GO


ALTER TABLE dbo.PostingsInThreads
ADD CONSTRAINT PK_PostingsInThreads_PostingInThreadID PRIMARY KEY (PostingInThreadID);
GO


CREATE NONCLUSTERED INDEX NCIX_PostingsInThreads_PostingThreadID
ON dbo.PostingsInThreads(PostingThreadID);
GO







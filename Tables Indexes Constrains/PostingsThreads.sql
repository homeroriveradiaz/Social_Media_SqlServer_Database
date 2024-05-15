USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[Postings]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PostingsThreads](
	[PostingThreadID] BIGINT IDENTITY(-9223372036854775808, 1) NOT NULL,
	[RootPostingID] BIGINT NOT NULL,
	[FirstPostingInThreadID] BIGINT NULL,
	[RespondingUserID] BIGINT NOT NULL
) ON [PRIMARY]

GO

ALTER TABLE dbo.PostingsThreads
ADD CONSTRAINT PK_PostingsThreads_PostingThreadID PRIMARY KEY (PostingThreadID);
GO

CREATE NONCLUSTERED INDEX NCIX_PostingsThreads_RootPostingID
ON dbo.PostingsThreads(RootPostingID);
GO



USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[HashtagsPostings]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HashtagsPostings](
	[PostingID] [bigint] NULL,
	[HashtagID] [bigint] NULL
) ON [PRIMARY]

GO


CREATE CLUSTERED INDEX CIX_HashtagsPostings_PostingID_HashtagID 
	ON [dbo].[HashtagsPostings]([PostingID], [HashtagID]);
GO

CREATE INDEX IX_HashtagsPostings_PostingID
	ON [dbo].[HashtagsPostings]([PostingID]);
GO
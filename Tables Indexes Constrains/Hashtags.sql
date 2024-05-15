USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[Hashtags]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Hashtags](
	[HashtagID] [bigint] IDENTITY(-9223372036854775808,1) NOT NULL,
	[Hashtag] [nvarchar](100) NULL
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Hashtags] ADD CONSTRAINT PK_Hasthags_HashtagID PRIMARY KEY ([HashtagID]);
GO


CREATE INDEX IX_Hashtags_Hashtag ON [dbo].[Hashtags](Hashtag);
GO
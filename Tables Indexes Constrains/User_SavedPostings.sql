USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[User_SavedPostings]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[User_SavedPostings](
	[UserID] [bigint] NULL,
	[PostingID] [bigint] NULL,
	[FollowDate] [smalldatetime] NULL
) ON [PRIMARY]

GO
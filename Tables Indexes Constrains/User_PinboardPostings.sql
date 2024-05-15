USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[User_PinboardPostings]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[User_PinboardPostings](
	[UserID] [bigint] NULL,
	[PostingID] [bigint] NULL,
	[ListHierarchy] [tinyint] NULL
) ON [PRIMARY]

GO

CREATE INDEX IX_User_PinboardPostings_UserID_INCLD_PostingID 
ON [dbo].[User_PinboardPostings]([UserID]) INCLUDE(PostingID);
GO

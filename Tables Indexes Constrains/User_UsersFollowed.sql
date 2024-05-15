USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[User_UsersFollowed]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[User_UsersFollowed](
	[UserID] [bigint] NULL,
	[UserIDFollowed] [bigint] NULL,
	[IsMute] [bit] NULL
) ON [PRIMARY]

GO
USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[NewUserTokens]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NewUserTokens](
	[UserID] [bigint] NULL,
	[Token] [nvarchar](100) NULL
) ON [PRIMARY]

GO
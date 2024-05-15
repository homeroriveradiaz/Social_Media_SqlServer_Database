USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[UsersPublicKey]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UsersPublicKey](
	[UserID] [bigint] NULL,
	[ShortenedName] [nvarchar](100) NULL,
	[ShortenedNameID] [bigint] IDENTITY(1,1) NOT NULL,
	[ShortenedNameFull] [nvarchar](200) NULL
) ON [PRIMARY]

GO
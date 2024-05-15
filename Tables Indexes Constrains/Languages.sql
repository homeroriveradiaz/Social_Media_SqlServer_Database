USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[Languages]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Languages](
	[LanguageID] [int] IDENTITY(1,1) NOT NULL,
	[Language] [nvarchar](100) NULL,
	[InService] [bit] NULL
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[Languages]
ADD CONSTRAINT PK_Languages_LanguageID PRIMARY KEY(LanguageID);

GO



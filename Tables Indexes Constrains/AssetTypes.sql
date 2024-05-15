USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[AssetTypes]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AssetTypes](
	[AssetTypeID] [tinyint] IDENTITY(1,1) NOT NULL,
	[AssetType] [nvarchar](100) NULL,
	[AssetDescription] [nvarchar](500) NULL
) ON [PRIMARY]

GO
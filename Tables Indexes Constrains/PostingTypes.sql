USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[PostingTypes]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PostingTypes](
	[PostingTypeID] [tinyint] IDENTITY(1,1) NOT NULL,
	[PostingType] [varchar](50) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO


IF NOT EXISTS(SELECT 1 FROM [dbo].[PostingTypes] WHERE PostingTypeID IN (1, 2)) BEGIN
	
	SET IDENTITY_INSERT [dbo].[PostingTypes] ON;

	INSERT INTO [dbo].[PostingTypes](PostingTypeID, PostingType)
	VALUES (1, 'Posting'), (2, 'Report');

	SET IDENTITY_INSERT [dbo].[PostingTypes] OFF;

END;
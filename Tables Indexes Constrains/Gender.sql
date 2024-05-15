USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[Gender]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Gender](
	[GenderID] [tinyint] IDENTITY(1,1) NOT NULL,
	[Gender] [varchar](10) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO


SET IDENTITY_INSERT [dbo].[Gender] ON;

INSERT INTO [dbo].[Gender]([GenderID], [Gender]) 
VALUES (1, 'Male'), (2, 'Female'), (3, 'NOYB');

SET IDENTITY_INSERT [dbo].[Gender] ON;

GO
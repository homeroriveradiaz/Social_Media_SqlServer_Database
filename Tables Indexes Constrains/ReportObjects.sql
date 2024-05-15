USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[ReportObjects]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReportObjects](
	[ObjectID] [tinyint] IDENTITY(1,1) NOT NULL,
	[ObjectDescription] [nvarchar](50) NULL
) ON [PRIMARY]

GO
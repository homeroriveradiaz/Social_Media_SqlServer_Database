USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[ReportTypes]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ReportTypes](
	[ReportTypeID] [int] IDENTITY(1,1) NOT NULL,
	[LanguageID] [int] NOT NULL,
	[ReportType] [nvarchar](250) NULL,
	[Active] [bit] NULL
) ON [PRIMARY]
GO


ALTER TABLE [dbo].[ReportTypes]
ADD CONSTRAINT PK_ReportTypes_ReportTypeID PRIMARY KEY(ReportTypeID);
GO

ALTER TABLE [dbo].[ReportTypes]
ADD CONSTRAINT FK_ReportTypes_LanguageID FOREIGN KEY (LanguageID) REFERENCES dbo.Languages(LanguageID);
GO




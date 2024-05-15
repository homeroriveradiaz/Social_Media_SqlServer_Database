USE ReadWrite_Prod;
GO
/****** Object:  Table [dbo].[DevicesVersionServiceMessages]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DevicesVersionServiceMessages](
	[VersionServiceID] [int] NULL,
	[LanguageID] [int] NULL,
	[ServiceMessage] [nvarchar](1000) NULL
) ON [PRIMARY];
GO

ALTER TABLE [dbo].[DevicesVersionServiceMessages]
ADD CONSTRAINT FK_DevicesVersionServiceMessages_VersionServiceID FOREIGN KEY (VersionServiceID) REFERENCES dbo.DevicesVersionServices(VersionServiceID)

GO

ALTER TABLE [dbo].[DevicesVersionServiceMessages]
ADD CONSTRAINT FK_DevicesVersionServiceMessages_LanguageID FOREIGN KEY (LanguageID) REFERENCES dbo.Languages(LanguageID);

GO
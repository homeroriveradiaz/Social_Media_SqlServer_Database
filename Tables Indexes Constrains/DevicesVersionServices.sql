USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[DevicesVersionServices]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DevicesVersionServices](
	[VersionServiceID] [int] IDENTITY(1,1) NOT NULL,
	[DeviceID] [int] NULL,
	[DeviceVersionID] [int] NULL,
	[UsesAPI] [int] NULL,
	[IsToBeDeprecated] [bit] NULL,
	[IsDeprecated] [bit] NULL,
	[VersionNotes] CHAR(100)
) ON [PRIMARY]
GO

ALTER TABLE dbo.DevicesVersionServices
ADD CONSTRAINT PK_DevicesVersionServices_VersionServiceID PRIMARY KEY(VersionServiceID);

GO

ALTER TABLE [dbo].[DevicesVersionServices]
ADD CONSTRAINT FK_DevicesVersionServices_DeviceID FOREIGN KEY(DeviceID) REFERENCES dbo.DevicesServiced(DeviceID);

GO



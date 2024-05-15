USE ReadWrite_Prod;
GO
/****** Object:  Table [dbo].[DevicesServiced]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DevicesServiced](
	[DeviceID] [int] IDENTITY(1,1) NOT NULL,
	[Device] [varchar](100) NULL,
	[Active] [bit] NULL
) ON [PRIMARY]

GO

ALTER TABLE dbo.DevicesServiced
ADD CONSTRAINT PK_DevicesServiced_DeviceID PRIMARY KEY(DeviceID ASC);



GO
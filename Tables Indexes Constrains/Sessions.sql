USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[Sessions]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sessions](
	[UserID] [bigint] NULL,
	[SessionToken] [nvarchar](500) NULL,
	[LastInteractionDate] [smalldatetime] NULL,
	[FromIPAddress] [decimal](38, 0) NULL,
	[IPAddressVersionID] [tinyint] NULL,
	[DeviceID] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Index [IX_Sessions_SessionToken]    Script Date: 27/09/2017 11:53:23 p. m. ******/
CREATE NONCLUSTERED INDEX [IX_Sessions_SessionToken] ON [dbo].[Sessions]
(
	[SessionToken] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Sessions_UserID]    Script Date: 27/09/2017 11:53:23 p. m. ******/
CREATE NONCLUSTERED INDEX [IX_Sessions_UserID] ON [dbo].[Sessions]
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
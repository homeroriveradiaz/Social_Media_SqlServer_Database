USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[Notifications_ForUserInterface]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Notifications_ForUserInterface](
	[NotificationID] [bigint] IDENTITY(-9223372036854775808,1) NOT NULL,
	[UserID] [bigint] NULL,
	[NotificationDate] [smalldatetime] NULL,
	[NotificationTypeID] [tinyint] NULL,
	[Value1] [bigint] NULL,
	[Value2] [bigint] NULL
) ON [PRIMARY]

GO
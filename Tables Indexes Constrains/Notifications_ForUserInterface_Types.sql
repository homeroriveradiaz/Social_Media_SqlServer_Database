USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[Notifications_ForUserInterface_Types]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Notifications_ForUserInterface_Types](
	[NotificationTypeID] [tinyint] IDENTITY(1,1) NOT NULL,
	[NotificationType] [varchar](50) NULL,
	[NotificationDescription] [varchar](300) NULL,
	[Active] [bit] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO


SET IDENTITY_INSERT [dbo].[Notifications_ForUserInterface_Types] ON;

INSERT INTO [dbo].[Notifications_ForUserInterface_Types](NotificationTypeID, NotificationType, NotificationDescription, Active)
VALUES (1, 'agenda', 'Is used to determine if a new user should be added to the agenda.', 1)
,(2, 'followers', 'A user followed/unfollowed the user. Triggers an update  on amount of followers on the GUI.', 1)
,(3, 'wishlist', 'Someone replied to a posting that belongs to the user. Triggers a flag towards the link to Profile page.', 1)
,(4, 'pinboard', 'Someone replied to a conversation on a posting from another user that this user is following. Should trigger a flag towards the Discover page.', 1)
,(5, 'posting deleted', 'Someone deleted a posting the user was following. Triggers a flag towards the Discover page.', 1);

SET IDENTITY_INSERT [dbo].[Notifications_ForUserInterface_Types] OFF;

GO


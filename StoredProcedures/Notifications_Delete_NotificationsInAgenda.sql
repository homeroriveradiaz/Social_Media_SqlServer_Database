USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[User_ThisUser_RemoveNotificationsOfType]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'Notifications_Delete_NotificationsInAgenda', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.Notifications_Delete_NotificationsInAgenda AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[Notifications_Delete_NotificationsInAgenda](
	@UserID BIGINT
) AS


DELETE dbo.Notifications_ForUserInterface
WHERE UserID = @UserID
	AND NotificationTypeID = 1;


GO
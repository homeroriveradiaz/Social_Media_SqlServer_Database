USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[User_ThisUser_RemoveNotificationID]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID(N'Notifications_Delete_ByNotificationID', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.Notifications_Delete_ByNotificationID AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[Notifications_Delete_ByNotificationID](
	@UserID BIGINT
	, @NotificationID BIGINT
)
AS


DELETE dbo.Notifications_ForUserInterface
WHERE NotificationID = @NotificationID
	AND UserID = @UserID;


GO
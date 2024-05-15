USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Notifications_ForWishList_Create]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID(N'Notifications_Update_Followers_Create', N'P') IS NULL BEGIN
	EXEC('CREATE PROC dbo.Notifications_Update_Followers_Create AS SELECT 1;');
END;
GO
/**************************************************************************
ALLOWS A RESPONDER TO RAISE NOTIFICATION TO POSTING AUTHOR
**************************************************************************/
ALTER PROCEDURE [dbo].[Notifications_Update_Followers_Create] (
	@UserID BIGINT
)
AS


IF NOT EXISTS(SELECT 1 FROM dbo.Notifications_ForUserInterface WITH(NOLOCK) WHERE NotificationTypeID = 1 AND UserID = @UserID) BEGIN

	INSERT INTO dbo.Notifications_ForUserInterface(UserID, NotificationDate, NotificationTypeID)	
	VALUES (@UserID, GETDATE(), 2);
	
END;



GO
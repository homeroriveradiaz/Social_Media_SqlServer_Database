USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Notifications_ForPinboard_Create]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'Notifications_Reply_To_RespondingUser_Create', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.Notifications_Reply_To_RespondingUser_Create AS SELECT 1;');
END;
GO

/****************************************************************************
RAISES A NOTIFICATION FOR A RESPONDER IN A POSTING
THIS IS TRIGGERED BY THE AUTHOR OF THE POSTING
****************************************************************************/
ALTER PROCEDURE [dbo].[Notifications_Reply_To_RespondingUser_Create](
	@ToUserID BIGINT
	, @RootPostingID BIGINT
)
AS


IF EXISTS(SELECT 1 FROM dbo.Notifications_ForUserInterface WITH(NOLOCK) WHERE UserID = @ToUserID AND NotificationTypeID = 4 AND  Value1 = @RootPostingID) BEGIN
	RETURN;
END; ELSE BEGIN
	INSERT INTO dbo.Notifications_ForUserInterface (UserID, NotificationDate, NotificationTypeID, Value1)
	VALUES (@ToUserID, GETDATE(), 4, @RootPostingID);
END




GO
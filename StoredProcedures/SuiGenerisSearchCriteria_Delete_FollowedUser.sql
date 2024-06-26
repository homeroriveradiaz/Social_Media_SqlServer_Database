USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[User_ThisUser_FollowedUnFollowUser]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'SuiGenerisSearchCriteria_Delete_FollowedUser', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.SuiGenerisSearchCriteria_Delete_FollowedUser AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[SuiGenerisSearchCriteria_Delete_FollowedUser](
	@UserID BIGINT,
	@TargetUser NVARCHAR(200)
)
AS

DECLARE @TargetUserID BIGINT;
SELECT @TargetUserID = UserID
FROM dbo.UsersPublicKey
WHERE ShortenedNameFull = @TargetUser;

DELETE dbo.User_UsersFollowed 
WHERE UserID = @UserID 
	AND UserIDFollowed = @TargetUserID;


IF (@@ROWCOUNT > 0) BEGIN

	IF NOT EXISTS(SELECT 1 FROM dbo.Notifications_ForUserInterface WITH(NOLOCK) WHERE NotificationTypeID = 1 AND UserID = @UserID) BEGIN

		INSERT INTO dbo.Notifications_ForUserInterface (UserID, NotificationDate, NotificationTypeID)
		VALUES (@UserID, GETDATE(), 1);
	END;

	IF NOT EXISTS(SELECT 1 FROM dbo.Notifications_ForUserInterface WITH(NOLOCK) WHERE NotificationTypeID = 2 AND UserID = @TargetUserID) BEGIN

		INSERT INTO dbo.Notifications_ForUserInterface (UserID, NotificationDate, NotificationTypeID)
		VALUES (@TargetUserID, GETDATE(), 2);
	END;

END;










GO
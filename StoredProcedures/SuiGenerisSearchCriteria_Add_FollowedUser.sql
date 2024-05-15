USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[User_ThisUser_FollowedUnFollowUser]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'SuiGenerisSearchCriteria_Add_FollowedUser', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.SuiGenerisSearchCriteria_Add_FollowedUser AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[SuiGenerisSearchCriteria_Add_FollowedUser](
	@UserID BIGINT,
	@TargetUser NVARCHAR(200)
)
AS


DECLARE @UserFollowed BIT = 0
	, @TargetUserID BIGINT;

SELECT @TargetUserID = UserID
FROM dbo.UsersPublicKey
WHERE ShortenedNameFull = @TargetUser;


IF EXISTS(SELECT 1 FROM dbo.User_UsersFollowed WITH(NOLOCK) WHERE UserID = @UserID AND UserIDFollowed = @TargetUserID) BEGIN

	RETURN;

END; ELSE BEGIN
	
	INSERT INTO dbo.User_UsersFollowed 
	VALUES (@UserID, @TargetUserID, 0);
	
	EXEC dbo.Notifications_Update_Agenda_Create
		@UserID = @UserID;

	EXEC dbo.Notifications_Update_Followers_Create
		@UserID = @TargetUserID;
	
END;



GO
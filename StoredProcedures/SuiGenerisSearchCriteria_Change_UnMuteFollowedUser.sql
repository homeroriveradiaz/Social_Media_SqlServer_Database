USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[UsersFollowed_ChangeFollowedUserMuteStatus]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'SuiGenerisSearchCriteria_Change_UnMuteFollowedUser', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.SuiGenerisSearchCriteria_Change_UnMuteFollowedUser AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[SuiGenerisSearchCriteria_Change_UnMuteFollowedUser](
	@UserID BIGINT,
	@TargetUser NVARCHAR(200)
)
AS

DECLARE @TargetUserID BIGINT;
SELECT @TargetUserID = UserID
FROM dbo.UsersPublicKey
WHERE ShortenedNameFull = @TargetUser;

UPDATE dbo.User_UsersFollowed
SET IsMute = 0
WHERE UserID = @UserID
	AND UserIDFollowed = @TargetUserID;



GO

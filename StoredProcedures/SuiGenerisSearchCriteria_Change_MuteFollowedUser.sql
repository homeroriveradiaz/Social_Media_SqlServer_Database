USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[UsersFollowed_ChangeFollowedUserMuteStatus]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'SuiGenerisSearchCritera_Change_MuteFollowedUser', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.SuiGenerisSearchCritera_Change_MuteFollowedUser AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[SuiGenerisSearchCritera_Change_MuteFollowedUser](
	@UserID BIGINT,
	@TargetUser NVARCHAR(200)
)
AS

DECLARE @TargetUserID BIGINT;
SELECT @TargetUserID = UserID
FROM dbo.UsersPublicKey
WHERE ShortenedNameFull = @TargetUser;

UPDATE dbo.User_UsersFollowed
SET IsMute = 1
WHERE UserID = @UserID
	AND UserIDFollowed = @TargetUserID;



GO
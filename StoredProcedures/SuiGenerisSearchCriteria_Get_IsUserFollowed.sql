USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[User_ThisUser_IsAnotherUserFollowed]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'SuiGenerisSearchCriteria_Get_IsUserFollowed', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.SuiGenerisSearchCriteria_Get_IsUserFollowed AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[SuiGenerisSearchCriteria_Get_IsUserFollowed](
	@UserID BIGINT,
	@TargetUser NVARCHAR(200)
)
AS
	

DECLARE @UserFollowed BIT = 0,
	@TargetUserID BIGINT;

SELECT @TargetUserID = UserID
FROM dbo.UsersPublicKey
WHERE ShortenedNameFull = @TargetUser;

IF EXISTS(SELECT 1 FROM dbo.User_UsersFollowed WHERE UserID = @UserID AND UserIDFollowed = @TargetUserID) BEGIN
	SET @UserFollowed = 1;
END;

SELECT (
	SELECT @UserFollowed AS userIsFollowed
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
) AS jsonString;


GO
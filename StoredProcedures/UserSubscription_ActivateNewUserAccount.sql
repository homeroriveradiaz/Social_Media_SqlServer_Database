USE ReadWrite_Prod;
GO


/****** Object:  StoredProcedure [dbo].[ActivateNewUserAccount]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO


IF OBJECT_ID(N'UserSubscription_ActivateNewUserAccount', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserSubscription_ActivateNewUserAccount AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[UserSubscription_ActivateNewUserAccount](
	@UserID BIGINT
	, @NewUserToken NVARCHAR(100)
	, @BackgroundImagePath VARCHAR(100) = NULL
	, @FemaleAvatarImagePath VARCHAR(100) = NULL
	, @MaleAvatarImagePath VARCHAR(100) = NULL
)
AS



IF (@BackgroundImagePath IS NULL OR @FemaleAvatarImagePath IS NULL OR @MaleAvatarImagePath IS NULL) BEGIN
	


	SELECT @BackgroundImagePath = 'demo-bg.png'
		, @FemaleAvatarImagePath = 'avatar-f.png'
		, @MaleAvatarImagePath = 'avatar-h.png';

END;



UPDATE dbo.Users
SET Active = 1
	, BackgroundImageURL = @BackgroundImagePath
	, AvatarImageURL = CASE WHEN Gender = 2 THEN @FemaleAvatarImagePath ELSE @MaleAvatarImagePath END
WHERE UserID = @UserID;


DELETE dbo.NewUserTokens
WHERE UserId = @UserID
	AND Token = @NewUserToken;


DELETE dbo.CaptchaUserRelationship
WHERE UserID = @UserID;



DECLARE @Name NVARCHAR(100);

SELECT @Name = [Name]
FROM dbo.Users
WHERE UserID = @UserID;

EXEC dbo.SuiGenerisSearchCriteria_Change_UserDescriptions
	@UserID = @UserID;



GO





CREATE OR ALTER PROC dbo.UserData_Get_Avatar
	@UserID BIGINT = NULL
	, @IsPublic BIT = 0
	, @UserPublicKey NVARCHAR(200) = NULL
AS


DECLARE @AvatarUrl NVARCHAR(200);

IF (@IsPublic = 0) BEGIN
	
	SELECT @AvatarUrl = dbo.fn_Get_Media_URL() + AvatarImageURL
	FROM dbo.Users
	WHERE UserID = @UserID;

END; ELSE BEGIN
	
	DECLARE @UID BIGINT = NULL;

	SELECT @UID = UserID
	FROM [dbo].[UsersPublicKey]
	WHERE [ShortenedNameFull] = @UserPublicKey;
	
	IF (@UID IS NOT NULL) BEGIN
		SELECT @AvatarUrl = dbo.fn_Get_Media_URL() + AvatarImageURL
		FROM dbo.Users
		WHERE UserID = @UID;
	END; ELSE BEGIN
		RAISERROR(N'Bad attempt to obtain use data recorded', 16, 1);
	END;

END;


SELECT (
	SELECT @AvatarUrl AS avatar
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
) AS jsonString;


GO

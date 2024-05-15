USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[LostPasswordTokens_ChangePasswordValidatingFirstAndRemove]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID(N'LostPassword_Change_Password', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.LostPassword_Change_Password AS SELECT 1;');
END;
GO


ALTER PROC [dbo].[LostPassword_Change_Password] (
	@Username NVARCHAR(100)
	, @Email NVARCHAR(100)
	, @Token NVARCHAR(100)
	, @Answer NVARCHAR(100)
	, @NewPassword NVARCHAR(100)
) AS


DECLARE @UserID BIGINT = NULL;


SELECT @UserID = UserID
FROM dbo.Users
WHERE Username = @Username
	AND ContactEmail = @Email
	AND SecurityAnswer = @Answer
	AND Active = 1
	AND Censored = 0;


IF (@UserID IS NULL) BEGIN
	RAISERROR(N'User not found or inactive or credentials invalid or arguments mismatch', 16, 1);
	RETURN;
END; ELSE BEGIN
	IF (EXISTS(SELECT 1 FROM dbo.LostPasswordTokens WHERE UserID = @UserID AND Token = @Token)) BEGIN

		UPDATE dbo.Users
		SET [Password] = @NewPassword
		WHERE Username = @Username
			AND ContactEmail = @Email
			AND SecurityAnswer = @Answer
			AND UserID = @UserID
			AND Active = 1
			AND Censored = 0;

		DELETE dbo.LostPasswordTokens
		WHERE UserID = @UserID
			AND Token = @Token

	END; ELSE BEGIN
		RAISERROR(N'There are no proceedings associated with this request.', 16, 1);
		RETURN;
	END;
END;



GO

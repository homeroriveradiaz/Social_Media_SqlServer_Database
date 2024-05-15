USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Login_ValidateUserAndPassword]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO


IF OBJECT_ID(N'UserLogin_ValidateUsernameAndPassword', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserLogin_ValidateUsernameAndPassword AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[UserLogin_ValidateUsernameAndPassword] (
	@Username NVARCHAR(100),
	@Password NVARCHAR(100)
)
AS

DECLARE @UserID BIGINT;

IF EXISTS(SELECT * FROM dbo.Users WITH(NOLOCK) WHERE Username = @username AND [Password] = @Password AND Active = 1 AND Censored = 0) BEGIN
	
	SELECT @UserID = UserID
	FROM dbo.Users WITH(NOLOCK)
	WHERE Username = @username 
		AND Password = @Password 
		AND Active = 1 
		AND Censored = 0;

END; ELSE BEGIN
	
	SET @UserID = -9000000000000000001;

END;


SELECT @UserID AS UserID;



GO
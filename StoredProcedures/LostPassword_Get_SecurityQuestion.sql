USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[LostPasswordTokens_VerifyTokenIsValid]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'LostPassword_Get_SecurityQuestion', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.LostPassword_Get_SecurityQuestion AS SELECT 1;');
END;
GO

ALTER PROC dbo.LostPassword_Get_SecurityQuestion(
	@Username NVARCHAR(100)
	, @Email NVARCHAR(100)
	, @Token NVARCHAR(100)
)
AS


DECLARE @Available BIT = 0
	, @SecurityQuestion NVARCHAR(100) = NULL
	, @Name NVARCHAR(100) = NULL;


SELECT @Available = 1
	, @SecurityQuestion = SecurityQuestion
	, @Name = [Name]
FROM dbo.Users AS U
WHERE U.Username = @Username
	AND U.ContactEmail = @Email
	AND U.Active = 1
	AND U.Censored = 0
	AND EXISTS (
		SELECT 1
		FROM dbo.LostPasswordTokens AS LPT
		WHERE LPT.UserID = U.UserID
			AND LPT.Token = @Token	
	);



IF (@Available = 0) BEGIN
	RAISERROR(N'Could not find username and email for password change related query.', 16, 1);
	RETURN;
END;


SELECT @SecurityQuestion AS SecurityQuestion
	, @Name AS [Name];


GO
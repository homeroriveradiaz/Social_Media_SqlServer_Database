USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[LostPasswordTokens_CreateToken]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'LostPassword_Create_Token', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.LostPassword_Create_Token AS SELECT 1;');
END;
GO

ALTER PROC [dbo].[LostPassword_Create_Token] (
	@Username NVARCHAR(100)
	, @Email NVARCHAR(100)
	, @Token NVARCHAR(100)
) AS



DECLARE @UserID BIGINT = NULL
	, @Name NVARCHAR(100) = NULL;


SELECT @UserID = UserID
	, @Name = [Name]
FROM dbo.Users
WHERE Active = 1
	AND Censored = 0
	AND Username = @Username
	AND ContactEmail = @Email;


IF (@UserID IS NULL) BEGIN
	RAISERROR(N'User not found.', 16, 1);
	RETURN;
END;


DELETE dbo.LostPasswordTokens
WHERE UserID = @UserID;


INSERT INTO dbo.LostPasswordTokens(UserID, Token, ExpirationDateTime)
VALUES (@UserID, @Token, DATEADD(mi, 20, GETUTCDATE()));


SELECT @Name AS [Name];


GO
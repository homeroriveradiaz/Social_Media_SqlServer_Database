USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[LostPasswordTokens_VerifyTokenIsValid]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'LostPassword_Validate_SecurityAnswer', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.LostPassword_Validate_SecurityAnswer AS SELECT 1;');
END;
GO

ALTER PROC dbo.LostPassword_Validate_SecurityAnswer(
	@Username NVARCHAR(100)
	, @Email NVARCHAR(100)
	, @SecurityAnswer NVARCHAR(100)
)
AS



DECLARE @Correct BIT = 0
	, @UserID BIGINT = NULL
	, @Name NVARCHAR(100) = NULL
	, @DefaultLanguageID INT = NULL
	, @EmailSubject NVARCHAR(MAX) = NULL
	, @EmailBody NVARCHAR(MAX) = NULL;


SELECT @Correct = 1
	, @UserID = UserID
	, @Name = Name
	, @DefaultLanguageID = DefaultLanguageID
FROM dbo.Users WITH(NOLOCK)
WHERE Username = @Username
	AND ContactEmail = @Email
	AND SecurityAnswer = @SecurityAnswer
	AND Active = 1
	AND Censored = 0;


IF (@Correct = 1) BEGIN
	
	SELECT @EmailSubject = dbo.fn_get_password_recovery_email_subject(@DefaultLanguageID)
		, @EmailBody = dbo.fn_get_password_recovery_email_body(@DefaultLanguageID);

END;


SELECT @Correct AS Correct
	, @UserID AS UserID
	, @Name AS Name
	, @EmailSubject AS EmailSubjectString
	, @EmailBody AS EmailBodySting;


GO

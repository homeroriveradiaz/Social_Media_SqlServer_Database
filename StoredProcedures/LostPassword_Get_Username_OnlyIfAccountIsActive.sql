USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[LostPasswordTokens_ChangePasswordValidatingFirstAndRemove]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'LostPassword_Get_Username_OnlyIfAccountIsActive', N'P') IS NULL BEGIN 
	EXEC(N'CREATE PROC dbo.LostPassword_Get_Username_OnlyIfAccountIsActive AS SELECT 1;');
END;
GO

/*********************************************************************************
When users are trying to recover their password, they may not even know what their 
username is.
They could know their email address though.

For such cases, we send their username by e-mail (provided that the account is
active and not frozen).

*********************************************************************************/
ALTER PROC dbo.LostPassword_Get_Username_OnlyIfAccountIsActive(
	@Email NVARCHAR(100)
) AS




DECLARE @Available BIT = 0
	, @UserID BIGINT = NULL
	, @Name NVARCHAR(100) = NULL
	, @Username NVARCHAR(100) = NULL
	, @DefaultLanguageID INT = NULL
	, @EmailSubject NVARCHAR(MAX) = NULL
	, @EmailBody NVARCHAR(MAX) = NULL;





SELECT @Available = 1
	, @UserID = UserID
	, @Name = Name
	, @Username = Username
	, @DefaultLanguageID = DefaultLanguageID
FROM dbo.Users WITH(NOLOCK)
WHERE ContactEmail = @Email
	AND Active = 1
	AND Censored = 0;


IF (@Available = 1) BEGIN
	
	SELECT @EmailSubject = dbo.fn_get_username_recovery_email_subject(@DefaultLanguageID)
		, @EmailBody = dbo.fn_get_username_recovery_email_body(@DefaultLanguageID);

END;



SELECT @Available AS Available
	, @Name AS Name
	, @Username AS Username
	, @EmailSubject AS EmailSubject
	, @EmailBody AS EmailBody
	, @UserID AS UserID;


GO



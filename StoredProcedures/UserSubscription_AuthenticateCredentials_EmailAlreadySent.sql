USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Subscriber_AuthenticateCredentials]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.UserSubscription_AuthenticateCredentials_EmailAlreadySent', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserSubscription_AuthenticateCredentials_EmailAlreadySent AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[UserSubscription_AuthenticateCredentials_EmailAlreadySent] (
	@UserID BIGINT,
	@NewUserToken NVARCHAR(100)
)
AS

DECLARE @Exists BIT = 0
	, @Name NVARCHAR(100) = NULL
	, @Email NVARCHAR(100) = NULL
	, @DefaultLanguageID INT = NULL


IF EXISTS(SELECT 1 FROM dbo.NewUserTokens WITH(NOLOCK) WHERE UserID = @UserID AND Token = @NewUserToken) BEGIN
	IF EXISTS(SELECT 1 FROM dbo.Users WHERE UserID = @UserID AND Active = 0 AND SecurityQuestion IS NOT NULL) BEGIN
		SELECT @Name = Name
			, @Email = ContactEmail
			, @DefaultLanguageID = DefaultLanguageID
			, @Exists = 1
		FROM dbo.Users WITH(NOLOCK)
		WHERE UserID = @UserID;
	END;
END;


SELECT @Exists AS [Exists]
	, ISNULL(@Name, N'') AS [Name]
	, ISNULL(@Email, N'') AS [Email]
	, ISNULL(@DefaultLanguageID, N'') AS [DefaultLanguageID];


GO
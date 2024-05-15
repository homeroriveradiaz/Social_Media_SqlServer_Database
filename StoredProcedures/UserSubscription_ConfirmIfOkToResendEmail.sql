USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Subscriber_VerifyIfEmailIsCorrect_AND_UserIsYetToActivate]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID(N'UserSubscription_ConfirmIfOkToResendEmail', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserSubscription_ConfirmIfOkToResendEmail AS SELECT 1;');
END;
GO

ALTER PROC [dbo].[UserSubscription_ConfirmIfOkToResendEmail](
	@UserID BIGINT
	, @Email NVARCHAR(100)
	, @NewUserToken NVARCHAR(100)
)
AS



DECLARE @OkToResendSubscriptionEmail BIT = 0;



IF EXISTS(
		SELECT 1 
		FROM dbo.Users WITH(NOLOCK) 
		WHERE UserID = @UserID 
			AND ContactEmail = @Email 
			AND Active = 0 
			AND Censored = 0
	)		
	AND EXISTS(
		SELECT 1 
		FROM dbo.CaptchaUserRelationship WITH(NOLOCK)
		WHERE UserID = @UserID
			AND Identified = 1
	) 
	AND EXISTS(
		SELECT 1 
		FROM dbo.UsersPublicKey WITH(NOLOCK)
		WHERE UserID = @UserID
	)
	AND EXISTS(
		SELECT 1
		FROM dbo.NewUserTokens WITH(NOLOCK)
		WHERE UserID = @UserID
			AND Token = @NewUserToken
	) BEGIN


	SET @OkToResendSubscriptionEmail = 1;

END;



SELECT @OkToResendSubscriptionEmail AS OkToResendSubscriptionEmail;




GO
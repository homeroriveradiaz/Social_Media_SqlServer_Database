USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[StoreCaptcha]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.UserSubscription_StoreNewCaptcha', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserSubscription_StoreNewCaptcha AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[UserSubscription_StoreNewCaptcha](
	@UserID BIGINT
	, @Captcha VARCHAR(50)
)
AS


DECLARE @CaptchaID BIGINT = -9000000000000000001;


IF NOT EXISTS(SELECT 1 FROM dbo.CaptchaUserRelationship WITH(NOLOCK) WHERE UserID = @UserID) BEGIN

	INSERT INTO dbo.CaptchaUserRelationship (UserID, Captcha, CaptchaDate, Identified)
	VALUES (@UserID, @captcha, GETDATE(), 0);	

	SELECT @CaptchaID = SCOPE_IDENTITY();

END;



SELECT @CaptchaID AS newCaptchaId;




GO
USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[StoreCaptchaUpdate]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.UserSubscription_StoreCaptchaUpdate', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserSubscription_StoreCaptchaUpdate AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[UserSubscription_StoreCaptchaUpdate](
	@CaptchaID BIGINT
	, @UserID BIGINT
	, @Captcha VARCHAR(50)
)
AS


UPDATE dbo.CaptchaUserRelationship
SET	 Captcha = @Captcha
WHERE CaptchaID = @CaptchaID
	AND UserID = @UserID
	AND Identified = 0;


GO
USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[CaptchaIsAccurate]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID(N'dbo.UserSubscription_VerifyCaptchaIsAccurate', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserSubscription_VerifyCaptchaIsAccurate AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[UserSubscription_VerifyCaptchaIsAccurate](
	@CaptchaID BIGINT
	, @UserID BIGINT
	, @Captcha VARCHAR(50)
)
AS



DECLARE @Valid BIT = 0;


IF EXISTS(SELECT 1 FROM dbo.CaptchaUserRelationship WITH(NOLOCK) WHERE CaptchaID = @CaptchaID AND UserID = @UserID AND Captcha = @Captcha AND Identified = 0) BEGIN
	SET @Valid = 1;
END;


SELECT @Valid AS [Valid];




GO
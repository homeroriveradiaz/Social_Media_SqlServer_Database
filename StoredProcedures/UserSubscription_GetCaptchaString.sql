USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[GetCaptchaString]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.UserSubscription_GetCaptchaString', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserSubscription_GetCaptchaString AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[UserSubscription_GetCaptchaString](
	@CaptchaID BIGINT,
	@UserID BIGINT
)
AS
	
	
SELECT Captcha
FROM dbo.CaptchaUserRelationship WITH(NOLOCK)
WHERE CaptchaID = @CaptchaID
	AND UserID = @UserID
	AND Identified = 0;




GO
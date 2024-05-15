USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[ReportCaptchaTokens_RemoveCaptcha]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'ReportPublic_Delete_Captcha', N'P') IS NULL BEGIN 
	EXEC(N'CREATE PROC dbo.ReportPublic_Delete_Captcha AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[ReportPublic_Delete_Captcha](
	@CaptchaID BIGINT
) AS

DELETE dbo.ReportCaptchaTokens 
WHERE ReportCapthaTokenID = @CaptchaID;


GO


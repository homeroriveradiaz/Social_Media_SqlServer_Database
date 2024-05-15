USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[ReportCaptchaTokens_ReassignCaptchaCode]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'ReportPublic_Change_CaptchaCode', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.ReportPublic_Change_CaptchaCode AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[ReportPublic_Change_CaptchaCode] (
	@CaptchaID BIGINT
	, @NewCaptcha VARCHAR(7)
)
AS

UPDATE dbo.ReportCaptchaTokens
SET Captcha = @NewCaptcha
WHERE ReportCapthaTokenID = @CaptchaID;



GO




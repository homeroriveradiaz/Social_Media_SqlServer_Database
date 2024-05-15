USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[ReportCaptchaTokens_GetCaptchaByReportCapthaTokenID]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'ReportPublic_Get_CaptchaByReportCapthaTokenID', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.ReportPublic_Get_CaptchaByReportCapthaTokenID AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[ReportPublic_Get_CaptchaByReportCapthaTokenID](
	@CaptchaID BIGINT
) AS


SELECT Captcha AS captcha
FROM dbo.ReportCaptchaTokens WITH(NOLOCK)
WHERE ReportCapthaTokenID = @CaptchaID
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;


GO
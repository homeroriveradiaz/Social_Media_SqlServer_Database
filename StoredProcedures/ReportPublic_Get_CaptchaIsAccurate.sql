USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[ReportCaptchaTokens_CaptchaIsAccurate]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'ReportPublic_Get_CaptchaIsAccurate', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.ReportPublic_Get_CaptchaIsAccurate AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[ReportPublic_Get_CaptchaIsAccurate](
	@CaptchaID BIGINT
	, @Captcha VARCHAR(7)
) AS

DECLARE @IsAccurate BIT = 0;

IF EXISTS(SELECT 1 FROM dbo.ReportCaptchaTokens WITH(NOLOCK) WHERE ReportCapthaTokenID = @CaptchaID AND Captcha = @Captcha) BEGIN
	SET @IsAccurate = 1
END;

SELECT @IsAccurate AS IsAccurate


GO
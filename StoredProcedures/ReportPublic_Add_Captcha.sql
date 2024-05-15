USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[ReportCaptchaTokens_CreateToken]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'ReportPublic_Add_Captcha', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.ReportPublic_Add_Captcha AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[ReportPublic_Add_Captcha] (
	@Captcha VARCHAR(7)
) AS


INSERT INTO dbo.ReportCaptchaTokens (Captcha, CaptchaCreationDate)
VALUES (@Captcha, GETDATE());


SELECT CAST(CAST(SCOPE_IDENTITY() AS BIGINT) AS VARCHAR) AS reportCapthaTokenId
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;


GO
USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[ReportCaptchaTokens_RemoveCaptchasOverTheTimeLimit]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'ReportPublic_Delete_CaptchasOverTimeLimit', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.ReportPublic_Delete_CaptchasOverTimeLimit AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[ReportPublic_Delete_CaptchasOverTimeLimit]
AS

DECLARE @LastPossibletime SMALLDATETIME = DATEADD(mi, -20, GETDATE());

DELETE dbo.ReportCaptchaTokens
WHERE CaptchaCreationDate < @LastPossibletime;


GO




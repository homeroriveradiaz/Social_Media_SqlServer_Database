USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[ReportAbuse_GetAllOptions]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'ReportAbuse_Get_ReportOptions', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.ReportAbuse_Get_ReportOptions AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[ReportAbuse_Get_ReportOptions] (
	@LanguageID INT
)
AS


SELECT ISNULL((
	SELECT ReportTypeID AS reportTypeID, ReportType AS reportType
	FROM dbo.ReportTypes WITH(NOLOCK)
	WHERE Active = 1
		AND LanguageID = @LanguageID
	ORDER BY ReportTypeID ASC
	FOR JSON PATH, ROOT('reportOptions')
), '{"reportOptions":[]}') AS jsonString;


GO
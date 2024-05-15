USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[SearchWords_GetListOfLIKESearchWords]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'SearchWords_Get_ListOfLikeSearchWords', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.SearchWords_Get_ListOfLikeSearchWords AS SELECT 1;');
END;
GO

ALTER PROC [dbo].[SearchWords_Get_ListOfLikeSearchWords] (
	@Argument NVARCHAR(100) 
) AS



SELECT ISNULL((
	SELECT TOP 8 Word AS word
	FROM dbo.SearchWords WITH(NOLOCK)
	WHERE Word LIKE '%' + @Argument + '%'
	FOR JSON PATH, ROOT('searchWords')
), '{"searchWords":[]}') AS jsonString;



GO
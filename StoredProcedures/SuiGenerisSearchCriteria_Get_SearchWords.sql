USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[SearchWords_GetUsersSearchWords]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'SuiGenerisSearchCriteria_Get_SearchWords', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.SuiGenerisSearchCriteria_Get_SearchWords AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[SuiGenerisSearchCriteria_Get_SearchWords](
	@UserID BIGINT
)
AS


SELECT ISNULL((
	SELECT USW.UserWordID as userWordId
		, SW.Word as word
	FROM dbo.User_SearchWords AS USW WITH(NOLOCK)
	INNER JOIN dbo.SearchWords AS SW WITH(NOLOCK) ON USW.SearchWordID = SW.SearchWordID
	WHERE USW.UserID = @UserID
	FOR JSON PATH, ROOT('searchWords')
), '{"searchWords":[]}') AS jsonString;


GO
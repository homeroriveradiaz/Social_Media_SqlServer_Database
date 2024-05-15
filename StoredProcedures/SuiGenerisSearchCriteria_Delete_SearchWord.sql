USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[SearchWords_DeleteUserWord]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'SuiGenerisSearchCriteria_Delete_SearchWord', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.SuiGenerisSearchCriteria_Delete_SearchWord AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[SuiGenerisSearchCriteria_Delete_SearchWord](
	@UserID BIGINT
	, @UserWordID INT
)
AS


DELETE dbo.User_SearchWords
WHERE UserID = @UserID 
	AND UserWordID = @UserWordID;


GO




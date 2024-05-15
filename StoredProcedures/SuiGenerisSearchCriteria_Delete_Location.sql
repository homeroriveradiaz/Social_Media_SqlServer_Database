USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Location_RemoveUserLocation]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID(N'SuiGenerisSearchCriteria_Delete_Location', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.SuiGenerisSearchCriteria_Delete_Location AS SELECT 1;')
END;
GO


ALTER PROCEDURE [dbo].[SuiGenerisSearchCriteria_Delete_Location](
	@UserID BIGINT
	, @UserRowID INT
)
AS


DELETE dbo.User_LocationsFollowed
WHERE UserID = @UserID
	AND UserRowID = @UserRowID;



GO



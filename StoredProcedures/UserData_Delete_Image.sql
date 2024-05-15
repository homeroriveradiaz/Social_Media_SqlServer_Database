USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Assets_GetAllUsersPictures]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.UserData_Delete_Image', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserData_Delete_Image AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[UserData_Delete_Image](
	@UserID BIGINT
	, @ImageID BIGINT
)
AS


UPDATE dbo.Images
SET Active = 0
WHERE ImageID = @ImageID
	AND UserID = @UserID;


GO
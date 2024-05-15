USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Assets_GetAllUsersPictures]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.UserData_Get_Image_ByUserIDAndImageID', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserData_Get_Image_ByUserIDAndImageID AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[UserData_Get_Image_ByUserIDAndImageID](
	@UserID BIGINT
	, @ImageID BIGINT
)
AS


IF EXISTS(SELECT 1 FROM dbo.Images WITH(NOLOCK) WHERE UserID = @UserID AND ImageID = @ImageID AND Active = 1) BEGIN

	SELECT [Image]
	FROM dbo.Images WITH(NOLOCK)
	WHERE UserID = @UserID
		AND ImageID = @ImageID
		AND Active = 1;

END ELSE BEGIN
	RAISERROR('No such image exists.', 16, 1);
END;


GO
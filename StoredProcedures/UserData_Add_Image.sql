USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Assets_AddNewUserPicture]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.UserData_Add_Image', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserData_Add_Image AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[UserData_Add_Image](
	@UserID BIGINT
	,@FileName VARCHAR(200)
)
AS


DECLARE @imageID BIGINT;

INSERT INTO dbo.Images (UserID, DateCreated, [Image], Active) 
VALUES (@UserID, GETDATE(), @FileName, 1);

SET @imageID = SCOPE_IDENTITY();


SELECT (
	SELECT CAST(@imageID AS VARCHAR) AS imageId, dbo.fn_Get_Media_URL() + @FileName AS [image]
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
) AS jsonString;



GO
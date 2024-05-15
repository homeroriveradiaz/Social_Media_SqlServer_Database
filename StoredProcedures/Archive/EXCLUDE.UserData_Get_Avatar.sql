USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Assets_GetAllUsersPictures]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.UserData_Get_Avatar', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserData_Get_Avatar AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[UserData_Get_Avatar](
	@UserID BIGINT
)
AS


DECLARE @MediaURL VARCHAR(200) = dbo.fn_Get_Media_URL();

SELECT @MediaURL + AvatarImageURL AS avatarImageURL 
FROM dbo.Users 
WHERE UserId = @UserID 
FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER;


GO
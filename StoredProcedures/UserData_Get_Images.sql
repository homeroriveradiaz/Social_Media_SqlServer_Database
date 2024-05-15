USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Assets_GetAllUsersPictures]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.UserData_Get_Images', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserData_Get_Images AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[UserData_Get_Images](
	@UserID BIGINT
)
AS

DECLARE @MediaURL VARCHAR(200) = dbo.fn_Get_Media_URL();

SELECT ISNULL((
	SELECT CAST(ImageID AS VARCHAR) AS imageId, @MediaURL + [Image] AS [image]
	FROM dbo.Images WITH(NOLOCK)
	WHERE UserID = @UserID
		AND Active = 1
	FOR JSON PATH, ROOT('images')
), '{"images":[]}')	AS jsonString;


GO
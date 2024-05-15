USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Profile_GetImagesThatBelongToProduct]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'UserData_Get_ProductsImages', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserData_Get_ProductsImages AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[UserData_Get_ProductsImages](
	@ProductID BIGINT
)
AS

DECLARE @MediaURL VARCHAR(200) = dbo.fn_Get_Media_URL();

SELECT ISNULL((
	SELECT @MediaURL + I.[Image] AS [image]
	FROM dbo.ProductsImages AS PIMG WITH(NOLOCK)
	INNER JOIN dbo.Images AS I WITH(NOLOCK) ON PIMG.ImageID = I.ImageID
	WHERE PIMG.ProductID = @ProductID
	FOR JSON PATH, ROOT('images')
), '{"images":[]}') AS jsonString;


GO



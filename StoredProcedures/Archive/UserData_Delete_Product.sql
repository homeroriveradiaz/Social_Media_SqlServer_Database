USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Profile_GetProducts]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'UserData_Delete_Product', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserData_Delete_Product AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[UserData_Delete_Product](
	@UserID BIGINT,
	@ProductID BIGINT
)
AS


UPDATE dbo.Products
SET Active = 0
WHERE ProductID = @ProductID
	AND UserID = @UserID;



GO


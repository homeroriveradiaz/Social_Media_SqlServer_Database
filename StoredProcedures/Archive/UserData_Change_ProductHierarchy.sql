USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Profile_GetProducts]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'UserData_Change_ProductHierarchy', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserData_Change_ProductHierarchy AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[UserData_Change_ProductHierarchy](
	@UserID BIGINT,
	@Direction VARCHAR(4),
	@ProductID BIGINT
)
AS


DECLARE @Hierarchy INT;

SELECT @Hierarchy = Hierarchy
FROM dbo.Products
WHERE ProductID = @ProductID
	AND UserID = @UserID;

IF @Hierarchy IS NULL BEGIN
	RAISERROR(N'Product hierarchy couldn''t be found because product doesnt''t exist or it doesn''t belong to this user.', 16, 1);
END;

IF @Hierarchy = 1 BEGIN
	RETURN;
END;




DECLARE @NewHierarchy INT
	, @TargetProductID BIGINT;

SET @NewHierarchy = 
	CASE WHEN @Direction = 'down' THEN @Hierarchy + 1
		WHEN @Direction = 'up' THEN @Hierarchy - 1
	END;

SELECT @TargetProductID = ProductID
FROM dbo.Products 
WHERE UserID = @UserID
	AND Hierarchy = @NewHierarchy;


IF @TargetProductID IS NULL BEGIN
	RETURN;
END; ELSE BEGIN

	UPDATE dbo.Products
	SET Hierarchy = 
		CASE ProductID WHEN @ProductID THEN @NewHierarchy
			WHEN @TargetProductID THEN @Hierarchy
		END
	WHERE ProductID IN (@ProductID, @TargetProductID)
		AND UserID = @UserID;

END;



GO
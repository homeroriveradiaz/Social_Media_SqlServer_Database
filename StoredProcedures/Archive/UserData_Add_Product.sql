USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Assets_AddNewProduct]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID(N'dbo.UserData_Add_Product', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserData_Add_Product AS SELECT 1;');
END;
GO

ALTER PROC [dbo].[UserData_Add_Product](
	@UserID BIGINT
	, @ProductName NVARCHAR(50)
	, @ProductDescription NVARCHAR(500)
	, @Price MONEY = NULL
	, @PriceCurrencyId INT = NULL
	, @MainImage NVARCHAR(200)
	, @ImagesString NVARCHAR(4000) = NULL
) AS


BEGIN TRY


	BEGIN TRANSACTION;



	DECLARE @Hierarchy INT = 1
		, @ProductID BIGINT
		, @Rowcount SMALLINT = 0;
	SET @MainImage = RIGHT(@MainImage, (CHARINDEX('/', REVERSE(@MainImage), 0)) - 1);


	IF EXISTS(SELECT 1 FROM dbo.Products WITH(NOLOCK) WHERE UserID = @UserID AND Active = 1) BEGIN

		SELECT @Hierarchy = MAX(Hierarchy) + 1
		FROM dbo.Products WITH(NOLOCK)
		WHERE UserID = @UserID 
			AND Active = 1;

	END;
	


	IF (@Price IS NOT NULL AND (NOT EXISTS(SELECT 1 FROM dbo.Currencies WITH(NOLOCK) WHERE CurrencyID = @PriceCurrencyId AND Active = 1))) BEGIN
		RAISERROR(N'Error attempting to create a product: the product is meant to have a price, but the currency does not exist or is not active.', 16, 1);		
	END;

	IF (NOT EXISTS(SELECT 1 FROM dbo.Images WITH(NOLOCK) WHERE UserID = @UserID AND [Image] = @MainImage AND Active = 1)) BEGIN
		RAISERROR(N'Attempting to use an image that doesn''t exist or doesn''t belong to user', 16, 1);
	END;




	SET @PriceCurrencyId = CASE WHEN @Price IS NULL THEN NULL ELSE @PriceCurrencyId END;

	INSERT INTO dbo.Products(UserID, DateCreated, ProductName, ProductDescription, Price, PriceCurrencyID, MainImage, Hierarchy, Active)
	VALUES (@UserID, GETDATE(), @ProductName, @ProductDescription, @Price, @PriceCurrencyId, @MainImage, @Hierarchy, 1);

	SET @ProductID = SCOPE_IDENTITY();


	INSERT INTO dbo.ProductsImages(ProductID, ImageID)
	SELECT @ProductID, I.ImageID
	FROM dbo.fn_break_string_in_brackets(@ImagesString) AS SIB
	INNER JOIN dbo.Images AS I WITH(NOLOCK) ON CAST(SIB.Items AS BIGINT) = I.[ImageID]
	WHERE I.UserID = @UserID
		AND I.Active = 1;


	SET @Rowcount = @@ROWCOUNT;


	UPDATE dbo.Products
	SET AttachedImagesCount = @Rowcount
	WHERE ProductID = @ProductID;



	COMMIT TRANSACTION;


	SELECT (
		SELECT CAST(@ProductID AS NVARCHAR(50)) AS productId
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	) AS jsonString;


END TRY
BEGIN CATCH
	
	IF (@@TRANCOUNT > 0) BEGIN
		ROLLBACK TRANSACTION;
	END;

	DECLARE @ErrorNumber INT = ERROR_NUMBER();
    DECLARE @ErrorLine INT = ERROR_LINE();
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
 
    PRINT 'Actual error number: ' + CAST(@ErrorNumber AS VARCHAR(10));
    PRINT 'Actual line number: ' + CAST(@ErrorLine AS VARCHAR(10));
 
    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);


END CATCH;



GO
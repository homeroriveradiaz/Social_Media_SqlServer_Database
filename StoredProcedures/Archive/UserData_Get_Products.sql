USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Profile_GetProducts]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'UserData_Get_Products', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserData_Get_Products AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[UserData_Get_Products](
	@UserID BIGINT = NULL
	, @IsPublic BIT = 0
	, @UserPublicKey NVARCHAR(200) = NULL
)
AS

DECLARE @MediaURL VARCHAR(200) = dbo.fn_Get_Media_URL();


IF (@IsPublic = 0) BEGIN

	SELECT ISNULL((
		SELECT CAST(P.ProductID AS NVARCHAR(40)) AS productId, P.ProductName AS productName
			, P.ProductDescription AS productDescription, @MediaURL + P.MainImage AS mainImage
			, P.Price AS price, C.CurrencySymbol AS currencySymbol
			, C.CurrencyAbbreviation AS currencyAbbreviation
			, (ISNULL((
				SELECT @MediaURL + I.[Image] AS [image]
				FROM dbo.ProductsImages AS PIMG WITH(NOLOCK)
				INNER JOIN dbo.Images AS I WITH(NOLOCK) ON PIMG.ImageID = I.ImageID
				WHERE PIMG.ProductID = P.ProductID
				FOR JSON AUTO
			), '[]')) AS images
		FROM dbo.Products AS P WITH(NOLOCK)
		LEFT JOIN dbo.Currencies AS C WITH(NOLOCK) ON P.PriceCurrencyID = C.CurrencyID
		WHERE P.UserID = @UserID
			AND P.Active = 1
		ORDER BY P.Hierarchy ASC
		FOR JSON PATH, ROOT('products')
	), '{"products":[]}') AS jsonString;

END; ELSE BEGIN

	DECLARE @UID BIGINT = NULL;

	SELECT @UID = UserID
	FROM [dbo].[UsersPublicKey]
	WHERE [ShortenedNameFull] = @UserPublicKey;
		
	IF (@UID IS NOT NULL) BEGIN
		SELECT ISNULL((
			SELECT CAST(P.ProductID AS NVARCHAR(40)) AS productId, P.ProductName AS productName
				, P.ProductDescription AS productDescription, @MediaURL + P.MainImage AS mainImage
				, P.Price AS price, C.CurrencySymbol AS currencySymbol
				, C.CurrencyAbbreviation AS currencyAbbreviation
				, (ISNULL((
					SELECT @MediaURL + I.[Image] AS [image]
					FROM dbo.ProductsImages AS PIMG WITH(NOLOCK)
					INNER JOIN dbo.Images AS I WITH(NOLOCK) ON PIMG.ImageID = I.ImageID
					WHERE PIMG.ProductID = P.ProductID
					FOR JSON AUTO
				), '[]')) AS images
			FROM dbo.Products AS P WITH(NOLOCK)
			LEFT JOIN dbo.Currencies AS C WITH(NOLOCK) ON P.PriceCurrencyID = C.CurrencyID
			WHERE P.UserID = @UID
				AND P.Active = 1
			ORDER BY P.Hierarchy ASC
			FOR JSON PATH, ROOT('products')
		), '{"products":[]}') AS jsonString;
	END; ELSE BEGIN
		RAISERROR(N'Bad attempt to obtain use data recorded', 16, 1);
	END;

END;


GO


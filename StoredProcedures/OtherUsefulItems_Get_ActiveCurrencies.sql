USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[GetActiveCurrencies]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'OtherUsefulItems_Get_ActiveCurrencies', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.OtherUsefulItems_Get_ActiveCurrencies AS SELECT 1;');
END;
GO

ALTER PROC [dbo].[OtherUsefulItems_Get_ActiveCurrencies] 
AS

	SELECT ISNULL((
		SELECT CurrencyID AS currencyId
			, CurrencySymbol + ' ' + CurrencyName + ' (' + CurrencyAbbreviation + ')' AS currencyLabel
		FROM dbo.Currencies WITH(NOLOCK)
		WHERE Active = 1
		ORDER BY CurrencySymbol
		FOR JSON PATH, ROOT('currencies')
	), '{"currencies":[]}') AS jsonString;

GO
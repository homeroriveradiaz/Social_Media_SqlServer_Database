/****** Object:  UserDefinedFunction [dbo].[fn_break_image_string_in_brackets]    Script Date: 11/03/2017 1:57:00 p. m. ******/
USE ReadWrite_Prod;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/***************************************************************************
	RETURNS THE DEFAULT SLOGAN TO USE IN NEW ACCOUNTS BY LANGUAGEID
***************************************************************************/
CREATE FUNCTION dbo.fn_default_businessdescription_for_languageid(
	@LanguageID INT
)
RETURNS NVARCHAR(500)
AS
BEGIN
	

	DECLARE @BusinessDescription NVARCHAR(100);


	SET @BusinessDescription = 
		CASE
			WHEN @LanguageID = 1 THEN N'Write a description of your business here (max. 500 characters)' --English
			WHEN @LanguageID = 2 THEN N'Escribe una breve reseña de tu negocio aquí (max. 500 caracteres)' --Spanish
		END;


	RETURN @BusinessDescription;

END
GO








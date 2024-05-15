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
CREATE FUNCTION dbo.fn_default_slogan_for_languageid(
	@LanguageID INT
)
RETURNS NVARCHAR(100)
AS
BEGIN
	

	DECLARE @Slogan NVARCHAR(100);


	SET @Slogan = 
		CASE
			WHEN @LanguageID = 1 THEN N'Write your slogan here' --English
			WHEN @LanguageID = 2 THEN N'Escribe tu slogan aquí' --Spanish
		END;


	RETURN @Slogan;

END
GO








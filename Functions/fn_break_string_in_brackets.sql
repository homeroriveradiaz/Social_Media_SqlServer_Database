/****** Object:  UserDefinedFunction [dbo].[fn_break_image_string_in_brackets]    Script Date: 11/03/2017 1:57:00 p. m. ******/
USE ReadWrite_Prod;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/***************************************************************************
WHEN POSTING OR RESPONDING TO POSTINGS, IMAGES COULD BE ADDED.
LOCATIONS COULD BE NEEDED TOO.

THEY'RE SENT IN THE FORM OF A BRACKETS STRING
AS IN...
	[IMAGES/1.JPG][IMAGES/IMG002.PNG][IMAGES/OTHER/IMG99.JPG][OTHER/IMAGES/1.GIF]

SO, WE WANT TO BREAK THIS INTO A CONVENIENT TABLE AS IN:
	--IMAGES--
	IMAGES/1.JPG
	IMAGES/IMG002.PNG
	IMAGES/OTHER/IMG99.JPG
	OTHER/IMAGES/1.GIF

***************************************************************************/
CREATE FUNCTION dbo.fn_break_string_in_brackets(
	@ItemsString NVARCHAR(MAX)
)
RETURNS @Items TABLE(Items NVARCHAR(MAX))
AS
BEGIN


	WHILE PATINDEX('%]%', @ItemsString) > 0 BEGIN
		
		INSERT INTO @Items(Items)
		VALUES (SUBSTRING(@ItemsString,2,PATINDEX('%]%', @ItemsString) - 2));

		SET @ItemsString = SUBSTRING(@ItemsString, PATINDEX('%]%', @ItemsString) + 1, LEN(@ItemsString));

	END;


	RETURN;


END
GO








/****** Object:  UserDefinedFunction [dbo].[fn_DisassembleString]    Script Date: 27/09/2017 11:53:22 p. m. ******/
USE ReadWrite_Prod;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_DisassembleString]
(
	@Str NVARCHAR(MAX)
)
RETURNS @Words TABLE (String NVARCHAR(100))
AS

BEGIN
	IF (PATINDEX('% %', @Str) = 0)
		BEGIN
			INSERT INTO @Words (String) VALUES (@Str)
		END
	ELSE
		BEGIN
			DECLARE @CurrStr AS NVARCHAR(100), @Remaining AS NVARCHAR(100)
			SET @Remaining = @Str
			
			WHILE (PATINDEX('% %', @Remaining) > 0)
			BEGIN
			
				SET @CurrStr = SUBSTRING(@Remaining, 1, PATINDEX('% %', @Remaining) - 1)
				INSERT INTO @Words (String) VALUES (@CurrStr)	
				SET @Remaining = RIGHT(@Remaining, LEN(@Remaining) - PATINDEX('% %', @Remaining))
				
				WHILE (PATINDEX('% %', @Remaining) = 1)
				BEGIN
					SET @Remaining = RIGHT(@Remaining, LEN(@Remaining) - PATINDEX('% %', @Remaining))
				END
				
			END
			
			INSERT INTO @Words VALUES (@Remaining)	
		END
		
RETURN
END


GO
/****** Object:  UserDefinedFunction [dbo].[fnhashtag_get_next_starting_position]    Script Date: 27/09/2017 11:53:22 p. m. ******/
USE ReadWrite_Prod;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[fnhashtag_get_next_starting_position]
(
	@String NVARCHAR(4000)
	, @AfterPosition INT
)
RETURNS BIGINT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @StartingPos BIGINT = NULL;

	
	IF (@AfterPosition IS NULL) BEGIN
		SET @StartingPos = PATINDEX(N'%#[a-z][a-z][a-z]%', @String);
	END;
	ELSE BEGIN
		SET @StartingPos = PATINDEX(N'%#[a-z][a-z][a-z]%', SUBSTRING(@String, @AfterPosition, 8000))
		
		IF (@StartingPos <> 0) BEGIN
			SET @StartingPos = @StartingPos + @AfterPosition-1;
		END;		
		
	END;



	-- Return the result of the function
	RETURN @StartingPos;

END

GO
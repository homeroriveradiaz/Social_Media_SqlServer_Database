/****** Object:  UserDefinedFunction [dbo].[fn_EvaluatePostVSKeywords]    Script Date: 27/09/2017 11:53:22 p. m. ******/
USE ReadWrite_Prod;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_EvaluatePostVSKeywords]
(
	@PostingTitle NVARCHAR(100)
	, @PostingBody NVARCHAR(4000)
	, @SearchWord NVARCHAR(100)
)
RETURNS MONEY
AS
BEGIN
	
	DECLARE @Value MONEY
	SET @Value = 0
	
	SET @Value = @Value + (  
		CAST(
			LEN(@PostingTitle) 
			- CASE	PATINDEX('%' + @SearchWord + ' %', @PostingTitle + ' ') 
					WHEN 0 THEN LEN(@PostingTitle) 
					ELSE PATINDEX('%' + @SearchWord + ' %', @PostingTitle + ' ')
			END AS MONEY) / LEN(@PostingTitle)
	)
		
	SET @Value = @Value + (  
		CAST(
			LEN(@PostingBody) 
			- CASE	PATINDEX('%' + @SearchWord + ' %', @PostingBody + ' ') 
					WHEN 0 THEN LEN(@PostingBody) 
					ELSE PATINDEX('%' + @SearchWord + ' %', @PostingBody + ' ')
			END AS MONEY) / LEN(@PostingBody)
	)		
	
	
	RETURN @Value
END


GO
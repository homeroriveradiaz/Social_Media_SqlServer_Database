/****** Object:  UserDefinedFunction [dbo].[fnha_ui_how_long_since_posting]    Script Date: 27/09/2017 11:53:22 p. m. ******/
USE ReadWrite_Prod;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fnha_ui_how_long_since_posting]
(
	@PostingDate AS DATETIME
	, @LanguageID AS INT
)
RETURNS NVARCHAR(500)
AS
BEGIN

	DECLARE @HowLongAgo NVARCHAR(500), @Seconds BIGINT;
	SET @Seconds = DATEDIFF(SS, @PostingDate, GETDATE());


	SET @HowLongAgo = 
		CASE @LanguageID
			WHEN 1 THEN --English
				CASE
					WHEN @Seconds <= 119 THEN 'seconds ago'
					WHEN @Seconds BETWEEN 129 AND 3599 THEN CAST(@Seconds / 60 AS NVARCHAR) + ' minutes ago'
					WHEN @Seconds BETWEEN 3600 AND 7200 THEN 'about an hour ago'
					WHEN @Seconds BETWEEN 7201 AND 86400 THEN CAST(@Seconds / 3600 AS NVARCHAR) + ' hours ago'
					WHEN @Seconds BETWEEN 86401 AND 172800 THEN 'a day ago'
					WHEN @Seconds BETWEEN 172801 AND 604800 THEN CAST(@Seconds / 86400 AS NVARCHAR) + ' days ago'
					WHEN @Seconds > 604800 THEN CONVERT(VARCHAR(12), @PostingDate, 107)
				END
			WHEN 2 THEN --Spanish
				CASE
					WHEN @Seconds <= 119 THEN 'hace unos segundos'
					WHEN @Seconds BETWEEN 129 AND 3599 THEN 'hace ' + CAST(@Seconds / 60 AS NVARCHAR) + ' minutos'
					WHEN @Seconds BETWEEN 3600 AND 7200 THEN 'hace cerca de una hora'
					WHEN @Seconds BETWEEN 7201 AND 86400 THEN 'hace ' + CAST(@Seconds / 3600 AS NVARCHAR) + ' horas'
					WHEN @Seconds BETWEEN 86401 AND 172800 THEN 'hace 1 día'
					WHEN @Seconds BETWEEN 172801 AND 604800 THEN 'hace ' + CAST(@Seconds / 86400 AS NVARCHAR) + ' dias'
					WHEN @Seconds > 604800 THEN CONVERT(VARCHAR(12), @PostingDate)
				END
			WHEN 3 THEN --Chinese
				NULL
			WHEN 4 THEN --Italian
				NULL
			WHEN 5 THEN --French
				NULL
			WHEN 6 THEN --German
				NULL
			WHEN 7 THEN --Swedish
				NULL
			WHEN 8 THEN --Dutch
				NULL
			WHEN 9 THEN --Japanese
				NULL
			WHEN 10 THEN --Korean
				NULL
			WHEN 11 THEN --Hindi
				NULL
		END

	RETURN @HowLongAgo;

END

GO
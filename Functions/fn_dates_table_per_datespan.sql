-- ==================================================================
-- Create Multi-Statement Function template for Azure SQL Database
-- ==================================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION dbo.fn_dates_table_per_datespan
(
	@StartDate DATE
	, @EndDate DATE
)
RETURNS 
@Dates TABLE 
(
	Dates DATE
)
AS
BEGIN

	WHILE @StartDate <= @EndDate BEGIN
		INSERT INTO @Dates(Dates) VALUES (@StartDate);
		SET @StartDate = DATEADD(DAY, 1, @StartDate);
	END;
	
	RETURN 
END
GO


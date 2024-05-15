CREATE OR ALTER PROC dbo.Visits_Get_CountOfVisits(
	@VisitingSectionID SMALLINT = NULL,
	@FromDate SMALLDATETIME = NULL,
	@ToDate SMALLDATETIME = NULL
) AS



/************** SET UP A BASE TABLE TO DISPLAY DATE AND TIME ******************/
DECLARE @DateTimeTable AS TABLE (
	VisitDate DATE
	, VisitHour SMALLINT
	, VisitingSectionID SMALLINT
);

IF (@FromDate IS NULL)
	SELECT TOP (1) @FromDate = DATEADD(HOUR, VisitHour, CAST(VisitDate AS smalldatetime))
	FROM dbo.Visits
	ORDER BY VisitRowID;

IF (@ToDate IS NULL)
	SET @ToDate = GETUTCDATE();

WHILE (@FromDate <= @ToDate) BEGIN

	INSERT INTO @DateTimeTable(VisitDate, VisitHour, VisitingSectionID)
	SELECT CAST(@FromDate AS date), DATEPART(HOUR, @FromDate), VisitingSectionID
	FROM dbo.VisitSections
	WHERE VisitingSectionID = ISNULL(@VisitingSectionID, VisitingSectionID)

	SET @FromDate = DATEADD(HOUR, 1, @FromDate);

END;




/************ NOW THE SELECT STATEMENT ***********/
SELECT VS.SectionDescription AS VisitDescription
	, DT.VisitDate
	, DT.VisitHour
	, SUM(V.AmountOfVisits) AS AmountOfVisits
FROM @DateTimeTable AS DT
LEFT JOIN dbo.Visits AS V ON DT.VisitingSectionID = V.VisitingSectionID 
	AND DT.VisitDate = V.VisitDate
	AND DT.VisitHour = V.VisitHour
JOIN dbo.VisitSections AS VS ON DT.VisitingSectionID = VS.VisitingSectionID
GROUP BY VS.SectionDescription
	, DT.VisitingSectionID
	, DT.VisitDate
	, DT.VisitHour
ORDER BY DT.VisitingSectionID, DT.VisitDate, DT.VisitHour;



GO

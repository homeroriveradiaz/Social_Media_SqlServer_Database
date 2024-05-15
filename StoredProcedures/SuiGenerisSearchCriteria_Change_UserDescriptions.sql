/**********************************************************************************

	UPDATES User_DescriptionSplitToSearchWords WHEN A USER CHANGES HIS/HER PEN NAME

**********************************************************************************/

CREATE OR ALTER PROC dbo.SuiGenerisSearchCriteria_Change_UserDescriptions(
	@UserID BIGINT
)
AS 



DECLARE @UserDescriptionFields NVARCHAR(1000);
DECLARE @DescriptionSplit AS TABLE (
	Word NVARCHAR(100)
);



SELECT @UserDescriptionFields = [Name] + ' ' + Slogan + ' ' + BusinessDescription
FROM dbo.Users
WHERE UserID = @UserID;



INSERT INTO @DescriptionSplit(Word)
SELECT DISTINCT LOWER(dbo.fn_StripNonAlphaNumericCharacters(CAST(VALUE AS nvarchar(100))))
FROM STRING_SPLIT(@UserDescriptionFields, ' ');

INSERT INTO dbo.SearchWords(Word)
SELECT DS.Word
FROM @DescriptionSplit AS DS
LEFT JOIN dbo.SearchWords AS SW ON DS.Word = SW.Word
WHERE SW.SearchWordID IS NULL;



SELECT @UserID AS UserID, SW.SearchWordID
	INTO #TempUserDescriptionWords
FROM @DescriptionSplit AS DS
JOIN dbo.SearchWords AS SW ON DS.Word = SW.Word;



INSERT INTO dbo.User_DescriptionSplitToSearchWords(UserID, SearchWordID)
SELECT TDS.UserID, TDS.SearchWordID
FROM #TempUserDescriptionWords AS TDS
LEFT JOIN dbo.User_DescriptionSplitToSearchWords AS UNSSW ON TDS.UserID = UNSSW.UserID
	AND TDS.SearchWordID = UNSSW.SearchWordID
WHERE UNSSW.UserID IS NULL;



DELETE UNSSW
FROM dbo.User_DescriptionSplitToSearchWords AS UNSSW
LEFT JOIN #TempUserDescriptionWords AS TDS ON UNSSW.UserID = TDS.UserID
	AND UNSSW.SearchWordID = TDS.SearchWordID
WHERE UNSSW.UserID = @UserID
	AND TDS.UserID IS NULL;



GO

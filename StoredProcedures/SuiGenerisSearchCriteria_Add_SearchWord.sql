USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[SearchWords_AddWordToUser]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'SuiGenerisSearchCriteria_Add_SearchWord', N'P') IS NULL BEGIN 
	EXEC(N'CREATE PROC dbo.SuiGenerisSearchCriteria_Add_SearchWord AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[SuiGenerisSearchCriteria_Add_SearchWord](
	@UserID BIGINT
	, @NewWord NVARCHAR(100)
)
AS


DECLARE @SearchWordID BIGINT = NULL
	, @UserWordID INT = NULL
	, @Added BIT = 0;



SET @NewWord = LOWER(dbo.fn_StripNonAlphaNumericCharacters(@NewWord));

SELECT @SearchWordID = SearchWordID
FROM dbo.SearchWords WITH(NOLOCK)
WHERE Word = @NewWord;

IF @SearchWordID IS NULL BEGIN
	
	INSERT INTO dbo.SearchWords(Word)
	VALUES (@NewWord);

	SET @SearchWordID = SCOPE_IDENTITY();

END;





SELECT @UserWordID = MAX(UserWordID) + 1
FROM dbo.User_SearchWords WITH(NOLOCK)
WHERE UserID = @UserID;


IF @UserWordID IS NULL BEGIN
	SET @UserWordID = -2147483648;
END;


INSERT INTO dbo.User_SearchWords(UserID, SearchWordID, UserWordID)
SELECT NW.UserID, @SearchWordID, @UserWordID
FROM (VALUES (@UserID, @SearchWordID)) AS NW(UserID, SearchWordID)
LEFT JOIN dbo.User_SearchWords AS USW WITH(NOLOCK) ON NW.UserID = USW.UserID
	AND NW.SearchWordID = USW.SearchWordID
WHERE USW.UserID IS NULL;


IF (@@ROWCOUNT = 0) BEGIN
	SELECT @Added = 0, @UserWordID = NULL;
END; ELSE BEGIN
	SET @Added = 1;
END;



SELECT (
	SELECT @Added AS added
		, @UserWordID AS userWordId
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
) AS jsonString;



GO
USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[User_ThisUser_ActivePostings]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO


IF OBJECT_ID(N'Postings_Collect_Words', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.Postings_Collect_Words AS SELECT 1;');
END;
GO

ALTER PROC dbo.Postings_Collect_Words(
	@PostingID BIGINT
	, @MessageTitle NVARCHAR(100)
	, @MessageBody NVARCHAR(4000)
) AS

DECLARE @FullMessageString NVARCHAR(MAX) = @MessageTitle + N' ' + @MessageBody;
DECLARE @SearchWords TABLE(Word NVARCHAR(100));
DECLARE @NewHashtags TABLE (Hashtag NVARCHAR(100));

INSERT INTO @SearchWords(Word)
SELECT DISTINCT TRIM(LOWER(dbo.fn_StripNonAlphaNumericCharacters(VALUE))) AS Word
FROM STRING_SPLIT(REPLACE(REPLACE(@FullMessageString, CHAR(13), N' '), CHAR(10), N' '), N' ');

INSERT INTO @NewHashtags(Hashtag)
SELECT DISTINCT TRIM(LOWER(dbo.fn_StripNonAlphaNumericCharacters(VALUE))) AS Word
FROM STRING_SPLIT(REPLACE(REPLACE(REPLACE(@FullMessageString, CHAR(13), N' '), CHAR(10), N' '), N'<', N' '), N' ')
WHERE LEFT(VALUE, 1) = '#';




INSERT INTO dbo.Hashtags(Hashtag)
SELECT DISTINCT TH.Hashtag
FROM @NewHashtags AS TH
LEFT JOIN dbo.Hashtags AS H WITH(NOLOCK) ON TH.Hashtag = H.Hashtag
WHERE H.HashtagID IS NULL;

DELETE dbo.HashtagsPostings
WHERE PostingID = @PostingID;

INSERT INTO dbo.HashtagsPostings(PostingID, HashtagID)
SELECT DISTINCT @PostingID, H.HashtagID
FROM @NewHashtags AS TH
INNER JOIN dbo.Hashtags AS H WITH(NOLOCK) ON TH.Hashtag = H.Hashtag;




INSERT INTO dbo.SearchWords(Word)
SELECT SW1.Word
FROM @SearchWords AS SW1
LEFT JOIN dbo.SearchWords AS SW2 ON SW1.Word = SW2.Word
WHERE SW2.SearchWordID IS NULL;

DELETE dbo.PostingsSearchWordsList
WHERE PostingID = @PostingID;

INSERT INTO dbo.PostingsSearchWordsList(PostingID, SearchWordID)
SELECT DISTINCT @PostingID, SW2.SearchWordID
FROM @SearchWords AS SW1
INNER JOIN dbo.SearchWords AS SW2 WITH(NOLOCK) ON SW1.Word = SW2.Word;


GO



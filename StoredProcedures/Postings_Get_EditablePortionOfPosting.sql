CREATE OR ALTER PROCEDURE dbo.Postings_Get_EditablePortionOfPosting(
	@PostingID BIGINT,
	@UserID BIGINT
) AS

SELECT (
	SELECT PostingTitle as postingTitle, PostingMessage as postingMessage 
	FROM dbo.Postings 
	WHERE PostingID = @PostingID
		AND PostedByUserID = @UserID
		AND Active = 1 
		AND Censored = 0
	FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
) AS JsonString;

GO
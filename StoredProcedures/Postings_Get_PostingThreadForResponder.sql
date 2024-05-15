USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[User_ThisUser_GetPostingsThatWereSaved]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[Postings_Get_PostingThreadForResponder](
	@UserID BIGINT
	, @LanguageID INT
	, @PostingID BIGINT
)
AS



DECLARE @PostingThreadID BIGINT;

SELECT @PostingThreadID = PostingThreadID
FROM dbo.PostingsThreads WITH (NOLOCK)
WHERE RootPostingID = @PostingID
	AND RespondingUserID = @UserID;

EXEC [dbo].[Postings_Get_PostingsInPostingsThreadID]
	@UserID = @UserID
	, @PostingThreadID = @PostingThreadID
	, @LanguageID = @LanguageID;




GO
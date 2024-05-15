USE ReadWrite_Prod;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'dbo.Postings_Clip_Posting', N'P') IS NULL BEGIN
	EXEC('CREATE PROC dbo.Postings_Clip_Posting AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[Postings_Clip_Posting](
	@UserID BIGINT
	, @PostingID BIGINT
)
AS


IF EXISTS (SELECT 1 FROM dbo.Postings WITH(NOLOCK) WHERE PostingID = @PostingID AND Active = 1 AND Censored = 0) BEGIN

	IF (EXISTS(SELECT 1 FROM dbo.User_SavedPostings WHERE UserID = @UserID AND PostingID = @PostingID))	BEGIN

		RETURN;

	END; ELSE BEGIN

		INSERT INTO dbo.User_SavedPostings 
		VALUES (@UserID, @PostingID, GETDATE());

		--We don't want to reprocess the whole user's search list because of a single clip, so, we just delete if it exists
		DELETE dbo.User_PinboardPostings
		WHERE UserID = @UserID 
			AND PostingID = @PostingID;
		
	END
END;



GO
USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Posting_EditPosting]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'dbo.Postings_Edit_Posting', N'P') IS NULL BEGIN
	EXEC('CREATE PROC dbo.Postings_Edit_Posting AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[Postings_Edit_Posting](
	@PostingID BIGINT
	, @MessageTitle NVARCHAR(100)
	, @MessageBody NVARCHAR(4000)
)
AS


UPDATE dbo.Postings
SET PostingTitle = @MessageTitle
	, PostingMessage = @MessageBody
WHERE PostingID = @PostingID;


/*********************************************************************
	COLLECT WORDS FOR SEARCH LISTS, COVERS HASHTAGS TOO
*********************************************************************/
EXEC dbo.Postings_Collect_Words
	@PostingID = @PostingID
	, @MessageTitle = @MessageTitle
	, @MessageBody = @MessageBody;


/*********************************************************************
	DELETE POSTING FROM EXISTING LISTS, SINCE IT COULD NO LONGER FIT
	(NOTE: WHEN POSTINGS ARE DELETED, THERE ARE FILTERS ALREADY
	IN PLACE. HERE WE ARE CONCERNED ABOUT USERS POTENTIALLY "CHEATING"
	IN ORDER TO SHOW IN SOME LISTS WHERE THE POSTING DOESN'T BELONG)
*********************************************************************/
DELETE dbo.User_PinboardPostings
WHERE PostingID = @PostingID;




GO
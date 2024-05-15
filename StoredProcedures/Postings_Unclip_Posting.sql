USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[User_ThisUser_UnsavePosting]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[Postings_Unclip_Posting] (
	@UserID BIGINT
	, @PostingID BIGINT
)
AS


DELETE dbo.User_SavedPostings 
WHERE UserID = @UserID 
	AND PostingID = @PostingID;

DELETE dbo.Notifications_ForUserInterface
WHERE UserID = @UserID
	AND NotificationTypeID = 4
	AND Value1 = @PostingID;

GO


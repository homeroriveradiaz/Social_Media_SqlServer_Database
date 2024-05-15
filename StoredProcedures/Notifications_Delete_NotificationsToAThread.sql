USE ReadWrite_Prod;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROC dbo.Notifications_Delete_NotificationsToAThread(
	@UserID BIGINT,
	@PostingThreadID BIGINT
) AS

/***********************************************************************

DELETES NOTIFICATIONS FOR A THREAD IN ONE OF THE POSTINGS THIS USER
CREATED.

IN OTHER WORDS, IF SOMEBEODY REPLIES TO A POSTING BY THIS USER, THIS 
USER GETS A NOTIFICATION IN THE THREAD THAT BELONGS TO THAT RESPONSE

WELL, THIS SP DELETES THAT NOTIFICATION

***********************************************************************/

DELETE [dbo].[Notifications_ForUserInterface]
WHERE UserID = @UserID
	AND NotificationTypeID = 3
	AND Value1 = @PostingThreadID;

GO
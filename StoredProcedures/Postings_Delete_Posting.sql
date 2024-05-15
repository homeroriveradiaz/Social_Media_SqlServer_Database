USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[User_DeletePostedMessage]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/******************************************************************************

DEACTIVATES A ROOT POSTING AND ALL ITEMS DEPENDING ON IT, SUCH AS NOTIFICATIONS
FOR USEER INTERFACE, 

******************************************************************************/
CREATE OR ALTER PROCEDURE [dbo].[Postings_Delete_Posting](
	@UserID BIGINT
	, @PostingID BIGINT
)
AS


/**** DESACTIVAR EL POSTING ****/
UPDATE dbo.Postings
SET Active = 0
WHERE PostingID = @PostingID
	AND PostedByUserID = @UserID;

/*** ELIMINAR HASHTAGS RELACIONADOS CON EL POSTING ***/
DELETE dbo.HashtagsPostings
WHERE PostingID = @PostingID;

		
/**** ELIMINAR LAS NOTIFICACIONES DE PINBOARD (4) PARA EL @PostingID ****/
DELETE dbo.Notifications_ForUserInterface
WHERE NotificationTypeID = 4
	AND Value1 = @PostingID;


/**** ELIMINAR LAS NOTIFICACIONES DE WISHLIST (3) PARA EL @UserID Y EL @PostingThreadID ****/
DELETE NFU
FROM dbo.PostingsThreads AS PT WITH(NOLOCK)
INNER JOIN dbo.Notifications_ForUserInterface AS NFU WITH(NOLOCK) ON PT.PostingThreadID = NFU.Value1
WHERE PT.RootPostingID = @PostingID
	AND NotificationTypeID = 3;


/**** INTERCAMBIAR PINNED POSTINGS DE PINBOARD (notification 4) POR DELETED MESSAGES (5) PARA EL @PostingID *****/
--INSERT INTO dbo.Notifications_ForUserInterface (UserID, NotificationDate, NotificationTypeID, Value1)
--SELECT UserID, GETDATE(), 5, @PostingID
--FROM dbo.User_SavedPostings
--WHERE PostingID = @PostingID;


/**** ELIMINAR LOS SAVED POSTINGS ****/
--DELETE dbo.User_SavedPostings
--WHERE PostingID = @PostingID;


/**** ELIMINAR UBICACIONES DE DICHO POSTING *****/
DELETE dbo.Postings_Locations
WHERE PostingID = @PostingID;


/**** ELIMINAR LAS PALABRAS DE BUSQUEDA ASOCIADEAS A DICHO POSTING *****/
DELETE dbo.PostingsSearchWordsList
WHERE PostingID = @PostingID;



GO
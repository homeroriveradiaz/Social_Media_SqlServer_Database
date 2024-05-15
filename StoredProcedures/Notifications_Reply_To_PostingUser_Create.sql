USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Notifications_ForWishList_Create]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID(N'Notifications_Reply_To_PostingUser_Create', N'P') IS NULL BEGIN
	EXEC('CREATE PROC dbo.Notifications_Reply_To_PostingUser_Create AS SELECT 1;');
END;
GO
/**************************************************************************
ALLOWS A RESPONDER TO RAISE NOTIFICATION TO POSTING AUTHOR
**************************************************************************/
ALTER PROCEDURE [dbo].[Notifications_Reply_To_PostingUser_Create] (
	@NotifyToUserID BIGINT
	, @PostingThreadID BIGINT
)
AS


IF EXISTS(SELECT 1 FROM dbo.Notifications_ForUserInterface WITH(NOLOCK) WHERE UserID = @NotifyToUserID AND NotificationTypeID = 3 AND Value1 = @PostingThreadID) BEGIN
	RETURN;
END; ELSE BEGIN

	--MAKE SURE ROOT POSTING IS ACTIVE BEFORE CREATING A NOTIFICATION!!
	IF EXISTS(
		SELECT 1
		FROM dbo.PostingsThreads AS PT WITH(NOLOCK)
		INNER JOIN dbo.Postings AS P WITH(NOLOCK) ON PT.RootPostingID = P.PostingID
		WHERE PT.PostingThreadID = @PostingThreadID
			AND P.Active = 1	
	) BEGIN
		INSERT INTO dbo.Notifications_ForUserInterface (UserID, NotificationDate, NotificationTypeID, Value1)
		VALUES (@NotifyToUserID, GETDATE(), 3, @PostingThreadID);
	END;

END;



GO
USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[User_DeletePostedMessage]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'Postings_Get_ThreadsInPosting', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.Postings_Get_ThreadsInPosting AS SELECT 1;');
END;
GO
/******************************************************************************

GIVES YOU ALL THREADS FOR A POSTING THE USER PUBLISHED

******************************************************************************/
ALTER PROC dbo.Postings_Get_ThreadsInPosting(
	@UserID BIGINT
	, @PostingID BIGINT
	, @LanguageID INT
) AS


DECLARE @MediaURL VARCHAR(200) = dbo.fn_Get_Media_URL();


SELECT ISNULL((
	SELECT CAST(PT.PostingThreadID AS NVARCHAR) AS postingThreadId
		, CAST(PT.RespondingUserID AS NVARCHAR) AS respondingUserId
		, dbo.fnha_ui_how_long_since_posting(PIT.PostDateTime, @LanguageID) AS postedOn
		, U.[Name] AS name
		, @MediaURL + U.AvatarImageURL AS avatar
		, CASE WHEN NFUI.NotificationID IS NOT NULL THEN 1 ELSE 0 END AS hasNotification
		, CAST(NFUI.NotificationId AS NVARCHAR) AS notificationId
		, CAST(CASE WHEN USP.UserID IS NULL THEN 0 ELSE 1 END AS BIT) AS threadActive
		, COUNT(PIT.PostingInThreadID) AS numberOfThreadMessages
	FROM dbo.Postings AS P WITH(NOLOCK)
	INNER JOIN dbo.PostingsThreads AS PT WITH (NOLOCK) ON P.PostingID = PT.RootPostingID
	INNER JOIN dbo.PostingsInThreads AS PIT WITH(NOLOCK) ON PT.FirstPostingInThreadID = PIT.PostingInThreadID
	INNER JOIN dbo.Users AS U WITH(NOLOCK) ON PT.RespondingUserID = U.UserID
	LEFT JOIN dbo.Notifications_ForUserInterface AS NFUI WITH(NOLOCK) ON NFUI.NotificationTypeID = 3 AND PT.PostingThreadID = NFUI.Value1
	LEFT JOIN dbo.User_SavedPostings AS USP ON P.PostingID = USP.PostingID AND USP.UserID = PT.RespondingUserID
	WHERE P.PostingID = @PostingID
		AND P.PostedByUserID = @UserID
		AND PT.RespondingUserID NOT IN (SELECT BannedUserID FROM dbo.User_BannedUsers WITH(NOLOCK) WHERE UserID = @UserID)
	GROUP BY PT.PostingThreadID, PT.RespondingUserID, dbo.fnha_ui_how_long_since_posting(PIT.PostDateTime, @LanguageID)
		, U.[Name], @MediaURL + U.AvatarImageURL, CASE WHEN NFUI.NotificationID IS NOT NULL THEN 1 ELSE 0 END
		, NFUI.NotificationId, CAST(CASE WHEN USP.UserID IS NULL THEN 0 ELSE 1 END AS BIT)
	ORDER BY PT.PostingThreadID
	FOR JSON PATH, ROOT('postingThreads'), INCLUDE_NULL_VALUES
), '{"postingThreads":[]}') AS jsonString;



GO
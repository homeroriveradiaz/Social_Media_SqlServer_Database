CREATE OR ALTER PROC dbo.Postings_Get_ThreadsForRespondingUser_DueToNotification(
	@UserID BIGINT
	, @LanguageID INT
) AS

DECLARE @MediaURL VARCHAR(200) = dbo.fn_Get_Media_URL();

SELECT ISNULL((
	SELECT CAST(NFI.Value1 AS NVARCHAR) AS postingId
		, VPR.UserPublicKey AS userPublicKey
		, VPR.PostingTitle AS postingTitle
		, VPR.Avatar AS avatar
		, VPR.[Name] AS [name]
		, (ISNULL((
			SELECT 
				CAST(PIT.PostingInThreadID AS NVARCHAR) AS postingInThreadId
				, CASE WHEN @UserID = PIT.PostedByUserID THEN 'responder' ELSE 'poster' END AS [by]
				, U.[Name] AS [name]
				, @MediaURL + U.AvatarImageURL AS avatar
				, dbo.fnha_ui_how_long_since_posting(PIT.PostDateTime, @LanguageID) AS [postedOn]
				, PIT.PostingMessage as [postingMessage]
				, (ISNULL((
						SELECT @MediaURL + I.[Image] AS [image]
						FROM dbo.PostingInThreadID_AttachedImages AS PITIM
						INNER JOIN dbo.Images AS I ON PITIM.ImageId = I.ImageId
						WHERE PITIM.PostingInThreadID = PIT.PostingInThreadID
						ORDER BY PITIM.PostingInThreadIDAttachedImagesID
						FOR JSON PATH
					), '[]')
				) as images
			FROM dbo.PostingsThreads AS PT
			INNER JOIN dbo.PostingsInThreads AS PIT ON PT.PostingThreadID = PIT.PostingThreadID
			INNER JOIN dbo.Users AS U ON PIT.PostedByUserID = U.UserID
			WHERE PT.RootPostingID = NFI.Value1
				AND PT.RespondingUserID = @UserID
			ORDER BY postingInThreadId DESC
			FOR JSON PATH
		), '[]')) as thread
	FROM dbo.Notifications_ForUserInterface AS NFI
	JOIN dbo.vw_postings_raw_data_for_search_lists AS VPR ON NFI.Value1 = VPR.PostingID
	WHERE NFI.UserID = @UserID
		AND NFI.NotificationTypeID = 4
	FOR JSON PATH, ROOT('postings'), INCLUDE_NULL_VALUES
), '{''postings'':[]}') AS JsonString;


DELETE dbo.Notifications_ForUserInterface
WHERE UserID = @UserID
	AND NotificationTypeID = 4;


GO

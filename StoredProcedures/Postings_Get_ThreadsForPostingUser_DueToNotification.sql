
CREATE OR ALTER PROC dbo.Postings_Get_ThreadsForPostingUser_DueToNotification(
	@UserID BIGINT
	, @LanguageID INT
) AS


DECLARE @MediaURL VARCHAR(200) = dbo.fn_Get_Media_URL();

SELECT ISNULL((
	SELECT CAST(VPR.PostingID AS VARCHAR) AS postingId, VPR.PostingTitle AS postingTitle
		, (ISNULL((		
			SELECT U.[Name] AS [name], @MediaURL + U.AvatarImageURL AS avatar
				, CAST(PT.PostingThreadID AS NVARCHAR) AS postingThreadId
				, (
					SELECT TOP (1) UPK.ShortenedNameFull
					FROM dbo.UsersPublicKey AS UPK 
					WHERE UPK.UserID = PT.RespondingUserID
					ORDER BY UPK.ShortenedNameID
				) AS userPublicKey
				, (
					SELECT CAST(PIT.PostingInThreadID AS NVARCHAR) AS postingInThreadId
						, CASE WHEN @UserID = PIT.PostedByUserID THEN 'poster' ELSE 'responder' END AS [by]
						, U1.[Name] AS [name]
						, @MediaURL + U1.AvatarImageURL AS avatar
						, dbo.fnha_ui_how_long_since_posting(PIT.PostDateTime, @LanguageID) AS [postedOn]
						, PIT.PostingMessage as [postingMessage]
						, (ISNULL((
							SELECT @MediaURL + I.[Image] AS [image]
							FROM dbo.PostingInThreadID_AttachedImages AS PITIM
							INNER JOIN dbo.Images AS I ON PITIM.ImageId = I.ImageId
							WHERE PITIM.PostingInThreadID = PIT.PostingInThreadID
							ORDER BY PITIM.PostingInThreadIDAttachedImagesID
							FOR JSON PATH
						), '[]')) as images
					FROM dbo.PostingsInThreads AS PIT
					INNER JOIN dbo.Users AS U1 ON PIT.PostedByUserID = U1.UserID
					WHERE PT.PostingThreadID = PIT.PostingThreadID
					ORDER BY PIT.PostingInThreadID
					FOR JSON PATH						
				) AS postingsInThread
			FROM dbo.PostingsThreads AS PT
			INNER JOIN dbo.Users AS U ON PT.RespondingUserID = U.UserID
			WHERE PT.RootPostingID = VPR.PostingID
			FOR JSON PATH
		), '[]')) as threads
FROM dbo.Notifications_ForUserInterface AS NFI
JOIN dbo.PostingsThreads AS PT ON NFI.Value1 = PT.PostingThreadID
JOIN dbo.vw_postings_raw_data_for_search_lists AS VPR ON PT.RootPostingID = VPR.PostingID
WHERE NFI.UserId = @UserID
	AND NFI.NotificationTypeID = 3
	AND (
		VPR.PostingTypeID = 1
		AND VPR.PostingActive = 1
		AND VPR.PostingCensored = 0
		AND VPR.PostingUserActive = 1
		AND VPR.PostingUserCensored = 0			
	)
ORDER BY VPR.PostingID DESC 
FOR JSON PATH, ROOT('postings'), INCLUDE_NULL_VALUES 
), '{"postings":[]}') AS JsonString;


DELETE dbo.Notifications_ForUserInterface
WHERE UserID = @UserID
	AND NotificationTypeID = 3;


GO
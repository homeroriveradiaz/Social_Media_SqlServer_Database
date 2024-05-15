CREATE OR ALTER PROC dbo.AccountSupervision_Delete_Account(
--This SP effectively wipes out all data concerning an account. Gone for good.
--OTHER related SPs we should create in the future are:
--AccountSupervision_Censor_Account When you want to penalize the account with a temporary ban
--AccountSupervision_Restore_Account when we want to allow user back to his/her account
--AccountSupervision_Deactivate_Account when we want to keep the user data 
	@UserID BIGINT
) 
AS



BEGIN TRANSACTION;
BEGIN TRY 


DELETE [dbo].[Sessions]
WHERE [UserID] = @UserID;

DELETE [dbo].[NewUserTokens]
WHERE [UserID] = @UserID;

DELETE [dbo].[LostPasswordTokens]
WHERE [UserID] = @UserID;

DELETE [dbo].[CaptchaUserRelationship]
WHERE [UserID] = @UserID;

DELETE [dbo].[UsersPublicKey]
WHERE [UserID] = @UserID;

DELETE [dbo].[User_DescriptionSplitToSearchWords]
WHERE [UserID] = @UserID;




--DELETE ANYTHING RELATED TO THE THREADS AND POSTINGS

--NOTIFICATIONS
DELETE [dbo].[Notifications_ForUserInterface]
WHERE [UserID] = @UserID
	OR (
		NotificationTypeID = 4 --When you saved a posting from another author, and you get a reply to this posting.
		AND Value1 IN (
			SELECT PostingID
			FROM dbo.Postings
			WHERE PostedByUserID = @UserID
		)
	)
	OR (
		NotificationTypeID = 3 --when someone else gets a notification to one of the threads from his/her posting
		AND Value1 IN (
			SELECT PostingThreadID
			FROM dbo.PostingsThreads
			WHERE RespondingUserID = @UserID
		)
	);

DELETE [dbo].[PostingInThreadID_AttachedImages]
WHERE PostingInThreadID IN (
	SELECT PostingInThreadID
	FROM [dbo].[PostingsInThreads]
	WHERE [PostingThreadID] IN (
		SELECT [PostingThreadID]
		FROM [dbo].[PostingsThreads]
		WHERE [RespondingUserID] = @UserID
			UNION
		SELECT [PostingThreadID]
		FROM [dbo].[PostingsThreads] AS PT
		JOIN dbo.Postings AS P ON PT.RootPostingID = P.PostingID
		WHERE P.[PostedByUserID] = @UserID
	)
);

DELETE [dbo].[PostingsInThreads]
WHERE [PostingThreadID] IN (
	SELECT [PostingThreadID]
	FROM [dbo].[PostingsThreads]
	WHERE [RespondingUserID] = @UserID
		UNION
	SELECT [PostingThreadID]
	FROM [dbo].[PostingsThreads] AS PT
	JOIN dbo.Postings AS P ON PT.RootPostingID = P.PostingID
	WHERE P.[PostedByUserID] = @UserID
);


DELETE [dbo].[PostingsThreads]
WHERE [RespondingUserID] = @UserID
	OR RootPostingID IN (
		SELECT PostingID
		FROM dbo.Postings
		WHERE PostedByUserID = @UserID
	);


DELETE [dbo].[AbuseReports]
WHERE [ReportingUserID] = @UserID;


DELETE dbo.PostingsSearchWordsList
WHERE PostingID IN (
	SELECT PostingID
	FROM dbo.Postings
	WHERE PostedByUserID = @UserID
);

DELETE [dbo].[HashtagsPostings]
WHERE [PostingID] IN (
	SELECT PostingID
	FROM dbo.Postings
	WHERE PostedByUserID = @UserID
);

DELETE [dbo].[Postings_AttachedImages]
WHERE [PostingID] IN (
	SELECT PostingID
	FROM dbo.Postings
	WHERE PostedByUserID = @UserID
);

DELETE [dbo].[Postings_Locations]
WHERE [PostingID] IN (
	SELECT PostingID
	FROM dbo.Postings
	WHERE PostedByUserID = @UserID
);

DELETE dbo.PublicSearchLists_Postings
WHERE PostingID IN (
	SELECT PostingID
	FROM dbo.Postings
	WHERE PostedByUserID = @UserID
);

DELETE dbo.PostingsCategories
WHERE PostingID IN (
	SELECT PostingID
	FROM dbo.Postings
	WHERE PostedByUserID = @UserID
);

DELETE [dbo].[Postings]
WHERE PostedByUserID = @UserID;








--User Sui Generis Search Criteria
DELETE [dbo].[User_SavedPostings]
WHERE UserID = @UserID;

DELETE [dbo].[User_SearchWords]
WHERE UserID = @UserID;

DELETE [dbo].[User_PinboardPostings]
WHERE UserID = @UserID;

DELETE [dbo].[User_UsersFollowed]
WHERE UserID = @UserID;

DELETE [dbo].[User_LocationsFollowed]
WHERE UserID = @UserID;




--User Articles
DELETE dbo.ArticleSection
WHERE ArticleID IN (
	SELECT ArticleID
	FROM dbo.Articles
	WHERE UserID = @UserID
);

DELETE dbo.Articles
WHERE UserID = @UserID;



--User Data
DELETE dbo.Addresses
WHERE UserID = @UserID;

DELETE dbo.Websites
WHERE UserID = @UserID;

DELETE dbo.Coverage
WHERE UserID = @UserID;

DELETE dbo.PhoneNumbers
WHERE UserID = @UserID;

DELETE dbo.Images
WHERE [UserID] = @UserID;




DELETE [dbo].[Users]
WHERE UserID = @UserID;



END TRY
BEGIN CATCH

	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRANSACTION;
	END;
	THROW;

END CATCH;


IF @@TRANCOUNT > 0 BEGIN
	COMMIT TRANSACTION;
	PRINT 'ACCOUNT DELETED';
END;


GO



USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[User_PostMessageResponse]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

/*********************************************************************************
THIS SPROC ALLOWS A USER TO REPLY TO A POSTING BY OTHER USER.
USES THE POSTINGID, 

	NEVER THE THREAD OR THREAD-POSTING.

*********************************************************************************/
CREATE OR ALTER PROC dbo.Postings_Add_ResponseToPosting(
	@UserID BIGINT
	, @MessageBody NVARCHAR(4000)
	, @IPAddress BIGINT
	, @PostedInResponseToPostingID BIGINT
	, @ImagesString NVARCHAR(4000) = NULL
	, @LanguageID INT
) AS


DECLARE @PostingThreadID BIGINT
	, @PostingInThreadID BIGINT
	, @SendEmailNotification BIT = 0
	, @ContactEmail NVARCHAR(100)
	, @RootPostingTitle NVARCHAR(100)
	, @AddreseeName NVARCHAR(100)
	, @ResponderName NVARCHAR(100)
	, @JsonString NVARCHAR(MAX);



/*************************************************************************
	PART I.
	CHECK IF A THREAD EXISTS. IF NOT, CREATE ONE.
	THEN POST INTO THE THREAD.

*************************************************************************/
IF EXISTS(
	SELECT 1 
	FROM [dbo].[vw_postings_raw_data_for_search_lists] WITH(NOLOCK) 
	WHERE (PostingID = @PostedInResponseToPostingID)
		AND (PostedByUserID = @UserID
			OR NOT( PostingActive = 1
				AND PostingCensored = 0
				AND PostingUserActive = 1
				AND PostingUserCensored = 0
				AND PostingTypeID = 1
			)
		)
) BEGIN
	/* CAN'T REPLY TO YOUR OWN POSTING, RIGHT? */
	RAISERROR('ILLEGAL OPERATION OR POSTING IS UNAVAILABLE.', 16, 1);
	RETURN;

END; ELSE IF EXISTS(
		SELECT 1 
		FROM dbo.PostingsThreads AS PT WITH(NOLOCK) 
		WHERE PT.RespondingUserID = @UserID 
			AND PT.RootPostingID = @PostedInResponseToPostingID	
	) BEGIN


	SELECT @PostingThreadID = MIN(PostingThreadID)
	FROM dbo.PostingsThreads AS PT WITH(NOLOCK) 
	WHERE PT.RespondingUserID = @UserID 
		AND PT.RootPostingID = @PostedInResponseToPostingID;

	INSERT INTO [dbo].[PostingsInThreads](PostingThreadID, PostedByUserID, PostDateTime, PostingMessage, FromIPAddress)
	VALUES (@PostingThreadID, @UserID, GETDATE(), @MessageBody, @IPAddress);

	SET @PostingInThreadID = SCOPE_IDENTITY();
	

END; ELSE BEGIN

	/*NO THREAD EXISTS, SO WE CREATE ONE*/
	INSERT INTO dbo.PostingsThreads(RootPostingID, RespondingUserID)
	VALUES (@PostedInResponseToPostingID, @UserID);

	SET @PostingThreadID = SCOPE_IDENTITY();


	INSERT INTO [dbo].[PostingsInThreads](PostingThreadID, PostedByUserID, PostDateTime, PostingMessage, FromIPAddress)
	VALUES (@PostingThreadID, @UserID, GETDATE(), @MessageBody, @IPAddress);

	SET @PostingInThreadID = SCOPE_IDENTITY();

	UPDATE dbo.PostingsThreads
	SET FirstPostingInThreadID = @PostingInThreadID
	WHERE PostingThreadID = @PostingThreadID;

END;



/*************************************************************************
	PART II.
	ATTACH IMAGES TO THE REPLY

*************************************************************************/
EXEC dbo.Postings_Add_ImagesToPostingInThreadID 
	@PostingInThreadID = @PostingInThreadID
	, @ImagesString = @ImagesString
	, @UserID = @UserID;



/*************************************************************************
	PART III.
	RAISE A USER-END NOTIFICATION FOR THE PERSON THAT IS BEING REPLIED TO

*************************************************************************/
DECLARE @PostingAuthorUserID BIGINT;

SELECT @PostingAuthorUserID = PostedByUserID
FROM dbo.Postings WITH(NOLOCK)
WHERE PostingID = @PostedInResponseToPostingID;


EXEC [dbo].[Notifications_Reply_To_PostingUser_Create] 
	@NotifyToUserID = @PostingAuthorUserID
	, @PostingThreadID = @PostingThreadID


/*************************************************************************
	PART IV.
	GET E-MAIL NOTIFICATION DATA

*************************************************************************/
SELECT @SendEmailNotification = SendEmailWhenTheyReplyToMyPostings
	, @ContactEmail = ContactEmail
	, @AddreseeName = Name
FROM dbo.Users WITH(NOLOCK)
WHERE UserID = @PostingAuthorUserID
	AND Active = 1
	AND Censored = 0;

IF (@SendEmailNotification = 1) BEGIN
	
	SELECT @RootPostingTitle = PostingTitle
	FROM dbo.Postings WITH(NOLOCK)
	WHERE PostingID = @PostedInResponseToPostingID;

	SELECT @ResponderName = Name
	FROM dbo.Users WITH(NOLOCK)
	WHERE UserID = @UserID;

	
END; ELSE BEGIN
	
	SELECT @ContactEmail = NULL
	, @AddreseeName = NULL;

END;


/*************************************************************************
	PART V.
	ATTEMPT TO CLIP POSTING IF NOT YET CLIPPED.
	THE SPROC USED ALREADY CHECKS IF ALREADY SAVED, NO RISK OF DUPLICATES 

*************************************************************************/
EXEC [dbo].[Postings_Clip_Posting]
	@UserID = @UserID
	, @PostingID = @PostedInResponseToPostingID;


/*************************************************************************
	PART VI.
	RETURN THE POSTING-IN-THREAD-ID AS WELL AS 
	ANY E-MAIL NOTIFICATION DATA

*************************************************************************/
EXEC [dbo].[Postings_Get_PostingInThreadByID]
	@UserID = @UserID,
	@PostingInThreadID = @PostingInThreadID,
	@LanguageID = @LanguageID,
	@JsonString = @JsonString OUTPUT;

SELECT @SendEmailNotification AS sendEmail
	, @ContactEmail AS sendEmailToAddress
	, @AddreseeName AS sendEmailToName
	, @RootPostingTitle AS sendEmailAboutPostingTitle
	, @ResponderName AS sendEmailAboutRespondingUser
	, @JsonString AS JsonString;





GO
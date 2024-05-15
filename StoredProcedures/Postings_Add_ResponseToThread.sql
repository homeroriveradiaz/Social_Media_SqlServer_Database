USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[User_PostMessageResponse]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROC dbo.Postings_Add_ResponseToThread(
	@UserID BIGINT				--The user issuing the response. THIS IS EXPECTED TO BE THE USER THAT ORGINALLY POSTED THIS
	, @MessageBody NVARCHAR(4000)
	, @IPAddress BIGINT
	, @PostingThreadID BIGINT	--The thread
	, @ImagesString NVARCHAR(4000) = NULL
	, @LanguageID INT
) AS


DECLARE @PostingInThreadID BIGINT
	, @RespondingToUserID BIGINT
	, @RootPostingID BIGINT
	, @SendEmailNotification BIT = 0
	, @ContactEmail NVARCHAR(100)
	, @RootPostingTitle NVARCHAR(100)
	, @AddreseeName NVARCHAR(100)
	, @ResponderName NVARCHAR(100)
	, @JsonString NVARCHAR(MAX);


/********************************************************************************
	PART I.
	MAKE SURE THERE IS A THREAD THAT CORRESPONDS TO A ROOT POSTING BY THIS USER
	ALSO MAKE SURE THE USER INTENDED FOR REPLY IS, INDEED, THE ORIGINAL RESPONDER.
	ALSO CHECK THE USER IS INDEED, FOLLOWING THE POST/THREAD

	IF ALL CRITERIA ARE MET, REPLY!

*********************************************************************************/
IF EXISTS(
	SELECT 1
	FROM dbo.PostingsThreads AS PT WITH(NOLOCK)
	INNER JOIN [dbo].[vw_postings_raw_data_for_search_lists] AS P WITH(NOLOCK) ON PT.RootPostingID = P.PostingID
	INNER JOIN [dbo].User_SavedPostings AS SP ON PT.RespondingUserID = SP.UserID
		AND PT.RootPostingID = SP.PostingID
	WHERE PT.PostingThreadID = @PostingThreadID
		AND P.PostedByUserID = @UserID
		AND (P.PostingActive = 1
			AND P.PostingCensored = 0
			AND P.PostingUserActive = 1
			AND P.PostingUserCensored = 0
			AND P.PostingTypeID = 1
		)
) BEGIN
	
	INSERT INTO [dbo].[PostingsInThreads](PostingThreadID, PostedByUserID, PostDateTime, PostingMessage, FromIPAddress)
	VALUES (@PostingThreadID, @UserID, GETDATE(), @MessageBody, @IPAddress);

	SET @PostingInThreadID = SCOPE_IDENTITY();

	SELECT @RootPostingID = RootPostingID
	FROM dbo.PostingsThreads WITH(NOLOCK)
	WHERE PostingThreadID = @PostingThreadID;


END; ELSE BEGIN
	
	RAISERROR('INVALID REQUEST TO RESPOND TO A THREAD. THE THREAD MAY NOT BELONG TO USER, OR THE ORIGINATING POSTING IS NO LONGER AVAILABLE', 16, 1);
	RETURN;

END;




SELECT @RespondingToUserID = RespondingUserID
FROM dbo.PostingsThreads AS PT WITH(NOLOCK)
WHERE PostingThreadID = @PostingThreadID;




/*************************************************************************
	PART II.
	ATTACH IMAGES TO THE REPLY

*************************************************************************/
EXEC dbo.Postings_Add_ImagesToPostingInThreadID 
	@PostingInThreadID = @PostingInThreadID
	, @ImagesString = @ImagesString
	, @UserID = @UserID;



/**************************************************************************
	PART III.
	RAISE A NOTIFICATION FOR USER-END

**************************************************************************/
EXEC [dbo].[Notifications_Reply_To_RespondingUser_Create]
	@ToUserID = @RespondingToUserID
	, @RootPostingID = @RootPostingID;



/***************************************************************************
	PART IV.
	GET THE E-MAIL NOTIFICATION DATA

***************************************************************************/

SELECT @SendEmailNotification = SendEmailWhenTheyReplyToMyReplies
	, @ContactEmail = ContactEmail
	, @AddreseeName = Name
FROM dbo.Users WITH(NOLOCK)
WHERE UserID = @RespondingToUserID
	AND Active = 1
	AND Censored = 0;

IF (@SendEmailNotification = 1) BEGIN
	
	SELECT @RootPostingTitle = PostingTitle
	FROM dbo.Postings WITH(NOLOCK)
	WHERE PostingID = @RootPostingID;

	SELECT @ResponderName = Name
	FROM dbo.Users WITH(NOLOCK)
	WHERE UserID = @UserID;
	
END; ELSE BEGIN
	
	SELECT @ContactEmail = NULL
	, @AddreseeName = NULL;

END;



/***************************************************************************
	PART V.
	RETURN THE PostingInThreadID GENERATED AS WELL
	AS THE E-MAIL NOTIFICATIONS DATA AND THE JSON
	RESPONSE

***************************************************************************/
EXEC [dbo].[Postings_Get_PostingInThreadByID]
	@UserID = @UserID,
	@PostingInThreadID = @PostingInThreadID,
	@LanguageID = @LanguageID,
	@JsonString = @JsonString OUTPUT;

SELECT @SendEmailNotification AS SendEmail
	, @ContactEmail AS SendEmailToAddress
	, @AddreseeName AS SendEmailToName
	, @RootPostingTitle AS SendEmailAboutPostingTitle
	, @ResponderName AS SendEmailAboutRespondingUser
	, @JsonString AS JsonString;


GO
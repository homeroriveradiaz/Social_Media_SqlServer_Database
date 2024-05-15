USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[User_ThisUser_ActivePostings]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID(N'Postings_Get_PostingsInPostingsThreadID', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.Postings_Get_PostingsInPostingsThreadID AS SELECT 1;');
END;
GO

/*********************************************************************
RETURNS ALL REPLIES IN A THREAD
*********************************************************************/
ALTER PROCEDURE [dbo].[Postings_Get_PostingsInPostingsThreadID](
	@UserID BIGINT
	, @PostingThreadID BIGINT
	, @LanguageID INT
)
AS



IF (
	EXISTS(
		SELECT 1
		FROM dbo.PostingsThreads WITH(NOLOCK)
		WHERE PostingThreadID = @PostingThreadID
			AND RespondingUserID = @UserID
	)
	OR EXISTS(
		SELECT 1
		FROM dbo.Postings
		WHERE PostingID IN (
				SELECT TOP 1 RootPostingID
				FROM dbo.PostingsThreads WITH(NOLOCK)
				WHERE PostingThreadID = @PostingThreadID
			)
			AND PostedByUserID = @UserID
	)
) BEGIN

	DECLARE @MediaURL VARCHAR(200) = dbo.fn_Get_Media_URL();

	SELECT ISNULL((
		SELECT CAST(PIT.PostingInThreadID AS NVARCHAR) AS postingInThreadID
			, CAST(PIT.PostedByUserID AS NVARCHAR) AS postedByUserID
			, PIT.PostingMessage AS postingMessage
			, dbo.fnha_ui_how_long_since_posting(PIT.PostDateTime, @LanguageID) AS postedOn
			, u.[Name] AS name
			, @MediaURL + u.AvatarImageURL AS avatar
			, (ISNULL((
				SELECT @MediaURL + I.[Image] AS image
				FROM dbo.PostingInThreadID_AttachedImages AS PAI WITH(NOLOCK)
				INNER JOIN dbo.Images I WITH(NOLOCK) ON PAI.ImageID = I.ImageID
				WHERE PIT.PostingInThreadID = PAI.PostingInthreadID
				FOR JSON AUTO
			), '[]')) AS images
		FROM dbo.PostingsInThreads AS PIT WITH(NOLOCK)
		INNER JOIN dbo.Users U WITH(NOLOCK) ON PIT.PostedByUserID = U.UserID
		WHERE PIT.PostingThreadID = @PostingThreadID
		ORDER BY PIT.PostDateTime ASC
		FOR JSON PATH, ROOT('postingsInThreads'), INCLUDE_NULL_VALUES
	), '{"postingsInThreads":[]}') AS jsonString;

END; ELSE BEGIN

	SELECT '{"postingsInThreads":[]}' AS jsonString;

END;

GO


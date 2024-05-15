CREATE OR ALTER PROC [dbo].[Postings_Get_PostingInThreadByID](
	@UserID BIGINT,
	@PostingInThreadID BIGINT,
	@LanguageID INT,
	@JsonString NVARCHAR(MAX) OUTPUT
) AS 

DECLARE @MediaURL VARCHAR(200) = dbo.fn_Get_Media_URL();

SET @JsonString = (
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
	WHERE PIT.PostingInThreadID = @PostingInThreadID
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
);

RETURN;

GO

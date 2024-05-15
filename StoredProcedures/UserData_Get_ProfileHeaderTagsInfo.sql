USE ReadWrite_Prod;
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'UserData_Get_ProfileHeaderTagsInfo', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserData_Get_ProfileHeaderTagsInfo AS SELECT 1;');
END;
GO

ALTER PROC dbo.UserData_Get_ProfileHeaderTagsInfo(
	@UserPublicKey NVARCHAR(200)
)
AS

DECLARE @keywords NVARCHAR(MAX)
	, @UserID BIGINT = NULL;

SELECT @UserID = UserID
FROM [dbo].[UsersPublicKey]
WHERE [ShortenedNameFull] = @UserPublicKey;


IF (@UserID IS NOT NULL) BEGIN 

	SELECT @keywords = STRING_AGG(keyword, ',')
	FROM (
		SELECT RTRIM(LTRIM(CAST(N.VALUE AS NVARCHAR(MAX)))) AS keyword 
		FROM dbo.Users AS U WITH(NOLOCK)
		CROSS APPLY STRING_SPLIT(U.[Name], N' ') AS N
		WHERE U.UserID = @UserID
			UNION
		SELECT keyword
		FROM (
			SELECT TOP 10 CAST(RTRIM(LTRIM(H.Hashtag)) AS NVARCHAR(MAX)) AS keyword
			FROM dbo.Postings AS P WITH(NOLOCK)
			INNER JOIN dbo.HashtagsPostings AS HP WITH(NOLOCK) ON P.PostingID = HP.PostingID
			INNER JOIN dbo.Hashtags AS H WITH(NOLOCK) ON H.HashtagID = HP.HashtagID
			WHERE P.PostedByUserID = @UserID
				ORDER BY P.PostingID DESC
		) AS TOP10
	) AS KW;

	SELECT CAST(
		(
			SELECT [Name] as [name]
				, [Slogan] as [metaDescription]
				, dbo.fn_Get_Media_URL() + U.AvatarImageURL as [avatar]
				, @keywords as keywords
			FROM dbo.Users AS U WITH(NOLOCK)
			WHERE U.UserID = @UserID
			FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
		) AS NVARCHAR(MAX)
	) AS JsonString;

END; ELSE BEGIN
	RAISERROR(N'Bad attempt to obtain use data recorded', 16, 1);
END;



GO



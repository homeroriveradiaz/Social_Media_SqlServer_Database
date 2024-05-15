USE ReadWrite_Prod;
GO

CREATE OR ALTER PROCEDURE [dbo].[OtherUsefulItems_Get_ListOfRecommendedArticles] (
	@UserID BIGINT = NULL --only necessary when, as a user, we are visiting profile. This will exclude ourselves from the recommended users list.
	, @UserPublicKey NVARCHAR(200) --public key of curre profile being explored
)
AS



DECLARE @UID BIGINT = NULL
	, @MediaURL VARCHAR(500) = dbo.fn_Get_Media_URL();

SELECT @UID = UserID
FROM [dbo].[UsersPublicKey]
WHERE [ShortenedNameFull] = @UserPublicKey;



IF (@UserID IS NOT NULL) BEGIN
	
	WITH MainArticles AS (
		SELECT TOP (4) UFD.UserIDFollowed AS userId
			, COUNT(DISTINCT UFB.UserID) AS totalFollowers
			, MAX(A.ArticleID) AS ArticleID
		FROM dbo.User_UsersFollowed AS UFB WITH(NOLOCK)
		JOIN dbo.User_UsersFollowed AS UFD WITH(NOLOCK) ON UFB.UserID = UFD.UserID
		JOIN dbo.Users AS U WITH(NOLOCK) ON UFD.UserIDFollowed = U.UserID 
			AND U.Active = 1 AND U.Censored = 0
		JOIN dbo.Articles AS A ON U.UserID = A.UserID
			AND A.Active = 1
		WHERE UFB.UserIDFollowed = @UID
			AND UFD.UserIDFollowed NOT IN (@UID, @UserID)
			AND UFD.UserIDFollowed NOT IN (
				SELECT UserIDFollowed 
				FROM dbo.User_UsersFollowed WITH(NOLOCK)
				WHERE UserID = @UserID
			)
		GROUP BY UFD.UserIDFollowed
		ORDER BY TotalFollowers DESC
	)
	SELECT ISNULL((
		SELECT (
				SELECT TOP (1) UPK.ShortenedNameFull
				FROM dbo.UsersPublicKey AS UPK
				WHERE UPK.UserID = U.UserID
				ORDER BY UPK.ShortenedNameID DESC
			) AS userPublicKey
			, @MediaURL + U.AvatarImageURL AS avatar
			, M.ArticleID AS articleId
			, MAX(CASE WHEN ARS.ArticleSectionID = 0 THEN ARS.ArticleSectionTextAndHtml END) AS headline
			, MAX(CASE WHEN ARS.ArticleSectionID = 1 THEN ARS.ArticleSectionTextAndHtml END) AS subHeadline
		FROM MainArticles AS M
		JOIN dbo.Users AS U ON M.userId = U.UserID
		JOIN dbo.Articles AS A ON M.ArticleID = A.ArticleID
		JOIN dbo.ArticleSection AS ARS ON A.ArticleID = ARS.ArticleID
		WHERE ARS.ArticleSectionID IN (0, 1)
		GROUP BY U.AvatarImageURL, U.UserID, M.ArticleID
		FOR JSON PATH, ROOT('articles')
	), '{"articles":[]}') AS jsonString;
	
END; ELSE BEGIN
	
	WITH MainArticles AS (
		SELECT TOP (4) UFD.UserIDFollowed AS userId
			, COUNT(DISTINCT UFB.UserID) AS totalFollowers
			, MAX(A.ArticleID) AS ArticleID
		FROM dbo.User_UsersFollowed AS UFB WITH(NOLOCK)
		JOIN dbo.User_UsersFollowed AS UFD WITH(NOLOCK) ON UFB.UserID = UFD.UserID
		JOIN dbo.Users AS U WITH(NOLOCK) ON UFD.UserIDFollowed = U.UserID
		JOIN dbo.Articles AS A ON UFD.UserID = A.UserID
			AND A.Active = 1
		WHERE UFB.UserIDFollowed = @UID
			AND UFD.UserIDFollowed <> @UID
			AND U.Active = 1 
			AND U.Censored = 0
		GROUP BY UFD.UserIDFollowed
		ORDER BY TotalFollowers DESC
	)
	SELECT ISNULL((
		SELECT (
				SELECT TOP (1) UPK.ShortenedNameFull
				FROM dbo.UsersPublicKey AS UPK
				WHERE UPK.UserID = U.UserID
				ORDER BY UPK.ShortenedNameID DESC
			) AS userPublicKey
			, @MediaURL + U.AvatarImageURL AS avatar
			, M.ArticleID AS articleId
			, MAX(CASE WHEN ARS.ArticleSectionID = 0 THEN ARS.ArticleSectionTextAndHtml END) AS headline
			, MAX(CASE WHEN ARS.ArticleSectionID = 1 THEN ARS.ArticleSectionTextAndHtml END) AS subHeadline
		FROM MainArticles AS M
		JOIN dbo.Users AS U ON M.userId = U.UserID
		JOIN dbo.Articles AS A ON M.ArticleID = A.ArticleID
		JOIN dbo.ArticleSection AS ARS ON A.ArticleID = ARS.ArticleID
		WHERE ARS.ArticleSectionID IN (0, 1)
		GROUP BY U.AvatarImageURL, U.UserID, M.ArticleID
		FOR JSON PATH, ROOT('articles')
	), '{"articles":[]}') AS jsonString;

END;



GO
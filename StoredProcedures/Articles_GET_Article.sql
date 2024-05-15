
CREATE OR ALTER PROC dbo.Articles_GET_Article(
	@UserPublicKey NVARCHAR(200) = NULL,
	@ArticleID BIGINT
)
AS

DECLARE @UID BIGINT = NULL;

SELECT @UID = UserID
FROM [dbo].[UsersPublicKey]
WHERE [ShortenedNameFull] = @UserPublicKey;

SELECT ISNULL(
	(
		SELECT AST.ArticleSectionAbbreviation AS sectionType, ARS.ArticleSectionTextAndHtml AS sectionContent
		FROM dbo.Articles AS A
		JOIN dbo.ArticleSection AS ARS ON A.ArticleID = ARS.ArticleID
		JOIN dbo.ArticleSectionType AS AST ON ARS.ArticleSectionTypeID = AST.ArticleSectionTypeID
		WHERE A.ArticleID = @ArticleID
			AND A.UserID = @UID
		ORDER BY ARS.ArticleSectionID
		FOR JSON PATH, ROOT('article')
	), '{"article":[]}'
) AS jsonString;

GO



CREATE OR ALTER PROC dbo.Articles_Add_NewArticle(
	@UserID BIGINT
	, @NewArticle dbo.NewArticleWithSections READONLY
)
AS

BEGIN TRANSACTION;

BEGIN TRY
	DECLARE @ArticleID BIGINT;

	INSERT INTO dbo.Articles(UserID, ArticleName)
	SELECT @UserID, SectionText
	FROM @NewArticle
	WHERE ArticleSectionTypeID = 0;

	IF @@ROWCOUNT <> 1 BEGIN
		RAISERROR(N'Article has fewer or more than 1 header. Cancelled.', 16, 1);
	END;

	SET @ArticleID = SCOPE_IDENTITY();

	INSERT INTO dbo.ArticleSection(ArticleID, ArticleSectionTypeID, ArticleSectionTextAndHtml)
	SELECT @ArticleID, ArticleSectionTypeID, SectionText
	FROM @NewArticle
	ORDER BY ParagraphOrder;

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK;
		THROW;
	END;

END CATCH;

IF @@TRANCOUNT > 0 BEGIN
	COMMIT;
END;

GO


CREATE TABLE dbo.ArticleSection(
	ArticleSectionID BIGINT IDENTITY(-9223372036854775808, 1) NOT NULL
	, ArticleID BIGINT NOT NULL
	, ArticleSectionTypeID TINYINT NOT NULL
	, ArticleSectionTextAndHtml NVARCHAR(MAX) NOT NULL
);
GO
CREATE INDEX IX_ArticleSection_ArticleID 
ON dbo.ArticleSection(ArticleID);
GO
ALTER TABLE dbo.ArticleSection
ADD CONSTRAINT FK_ArticleSection_ArticleID 
	FOREIGN KEY (ArticleID) REFERENCES dbo.Articles(ArticleID);
GO
ALTER TABLE dbo.ArticleSection
ADD CONSTRAINT FK_ArticleSection_ArticleSectionTypeID 
	FOREIGN KEY (ArticleSectionTypeID) REFERENCES dbo.ArticleSectionType(ArticleSectionTypeID);
GO



CREATE TYPE dbo.NewArticleWithSections AS TABLE (
	ParagraphOrder INT IDENTITY(1, 1)
	, ArticleSectionTypeID INT
	, SectionText NVARCHAR(MAX)
);
GO


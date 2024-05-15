

CREATE TABLE dbo.AdsParentCategories(
	ParentCategoryID INT IDENTITY(1, 1)
	, CategoryName NVARCHAR(100) NOT NULL
	, LanguageId INT NOT NULL
	, ColumnId INT NULL
	, RankId INT NULL
	, Active BIT
	, CreatedDate SMALLDATETIME DEFAULT(GETUTCDATE())
);
GO
ALTER TABLE dbo.AdsParentCategories ADD CONSTRAINT PK_AdsParentCategories_ParentCategoryID PRIMARY KEY (ParentCategoryID);
GO


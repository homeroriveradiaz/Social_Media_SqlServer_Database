


CREATE TABLE dbo.AdsChildCategories(
	ChildCategoryId INT IDENTITY(1, 1) 
	, ParentCategoryID INT
	, CategoryName NVARCHAR(100) NOT NULL
	, LanguageId INT NOT NULL
	, RankId INT NULL
	, Active BIT
	, CreatedDate SMALLDATETIME DEFAULT(GETUTCDATE())
);
GO
ALTER TABLE dbo.AdsChildCategories ADD CONSTRAINT PK_AdsChildCategories_ChildCategoryId PRIMARY KEY (ChildCategoryId);
GO
ALTER TABLE dbo.AdsChildCategories ADD CONSTRAINT FK_AdsChildCategories_ParentCategoryID FOREIGN KEY (ParentCategoryID) REFERENCES dbo.AdsParentCategories(ParentCategoryID)
GO

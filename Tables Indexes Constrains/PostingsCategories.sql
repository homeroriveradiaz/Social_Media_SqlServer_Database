
CREATE TABLE dbo.PostingsCategories(
	PostingID BIGINT
	, ChildCategoryID INT
);
GO
ALTER TABLE dbo.PostingsCategories ADD CONSTRAINT FK_PostingsCategories_PostingID FOREIGN KEY (PostingID) REFERENCES dbo.Postings(PostingID);
GO
ALTER TABLE dbo.PostingsCategories ADD CONSTRAINT FK_PostingsCategories_ChildCategoryID FOREIGN KEY (ChildCategoryID) REFERENCES dbo.AdsChildCategories(ChildCategoryID);
GO



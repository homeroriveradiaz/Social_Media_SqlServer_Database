CREATE TABLE dbo.PublicSearchLists_SearchWords(
	PublicSearchLists_SearchWords_ID BIGINT IDENTITY(-9223372036854775808, 1) NOT NULL,
	PublicSearchListID BIGINT NOT NULL,
	SearchWordID BIGINT NOT NULL
);
GO
ALTER TABLE dbo.PublicSearchLists_SearchWords 
ADD CONSTRAINT PK_PublicSearchLists_SearchWords_ID PRIMARY KEY NONCLUSTERED (PublicSearchLists_SearchWords_ID);
GO
ALTER TABLE dbo.PublicSearchLists_SearchWords 
ADD CONSTRAINT FK_PublicSearchLists_SearchWords_PublicSearchListID FOREIGN KEY (PublicSearchListID) 
REFERENCES dbo.PublicSearchLists(PublicSearchListID);
GO
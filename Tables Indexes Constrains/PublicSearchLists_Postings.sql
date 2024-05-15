CREATE TABLE dbo.PublicSearchLists_Postings(
	PublicSearchListID BIGINT NOT NULL,
	PostingID BIGINT NOT NULL
);
GO
ALTER TABLE dbo.PublicSearchLists_Postings
ADD CONSTRAINT FK_PublicSearchLists_Postings_PublicSearchListID FOREIGN KEY (PublicSearchListID)
REFERENCES dbo.PublicSearchLists(PublicSearchListID);
GO
CREATE INDEX IX_PublicSearchLists_Postings_PublicSearchListID_PostingID
ON dbo.PublicSearchLists_Postings(PublicSearchListID, PostingID DESC);
GO
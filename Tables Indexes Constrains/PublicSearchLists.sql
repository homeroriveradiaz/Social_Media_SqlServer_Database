CREATE TABLE dbo.PublicSearchLists(
	PublicSearchListID BIGINT IDENTITY(-9223372036854775808, 1) NOT NULL,
	LanguageID INT NOT NULL,
	CityID INT NOT NULL,
	CreatedDate SMALLDATETIME NOT NULL DEFAULT(GETUTCDATE()),
	LastUpdatedDate SMALLDATETIME NOT NULL DEFAULT(GETUTCDATE())
);
GO
ALTER TABLE dbo.PublicSearchLists 
ADD CONSTRAINT PK_PublicSearchLists_PublicSearchListID PRIMARY KEY (PublicSearchListID);
GO
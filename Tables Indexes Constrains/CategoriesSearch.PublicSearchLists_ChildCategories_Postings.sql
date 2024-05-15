CREATE TABLE CategoriesSearch.PublicSearchLists_ChildCategories_Postings(
	PublicSearchLists_ChildCategories_ID BIGINT
	, PostingID BIGINT
);
GO
alter table CategoriesSearch.PublicSearchLists_ChildCategories_Postings 
add constraint PK_PublicSearchLists_ChildCategories_Postings_ID 
primary key (PublicSearchLists_ChildCategories_ID);
GO
CREATE INDEX IX_PublicSearchLists_ChildCategories_Postings 
ON CategoriesSearch.PublicSearchLists_ChildCategories_Postings(PublicSearchLists_ChildCategories_ID, PostingID)
GO


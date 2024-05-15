CREATE TABLE CategoriesSearch.PublicSearchLists_ChildCategories
(
	PublicSearchLists_ChildCategories_ID BIGINT IDENTITY(-9223372036854775808, 1) NOT NULL
	, ChildCategoryID INT NOT NULL
	, CityID INT NOT NULL
	, CreatedDate SMALLDATETIME
	, LastUpdatedDate SMALLDATETIME
);
GO 
alter table CategoriesSearch.PublicSearchLists_ChildCategories 
add constraint PK_PublicSearchLists_ChildCategories_ID 
primary key (PublicSearchLists_ChildCategories_ID);
GO
alter table CategoriesSearch.PublicSearchLists_ChildCategories 
add constraint FK_PublicSearchLists_ChildCategoryID 
foreign key (ChildCategoryID) 
references dbo.AdsChildCategories(ChildCategoryID);
GO
create index IX_PublicSearchLists_ChildCategories 
ON CategoriesSearch.PublicSearchLists_ChildCategories(ChildCategoryID, CityID);
GO
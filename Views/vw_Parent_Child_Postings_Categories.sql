
CREATE OR ALTER VIEW dbo.vw_Parent_Child_Postings_Categories
AS

SELECT APC.ParentCategoryID, APC.CategoryName AS ParentCategoryName
	, APC.LanguageId, APC.ColumnId, APC.RankId AS ParentRankId 
	, ACC.ChildCategoryId, ACC.CategoryName AS ChildCategoryName
	, ACC.RankId AS ChildRankId
FROM dbo.AdsParentCategories AS APC
JOIN dbo.AdsChildCategories AS ACC ON
	APC.ParentCategoryID = ACC.ParentCategoryID
WHERE APC.Active = 1
	AND ACC.Active = 1






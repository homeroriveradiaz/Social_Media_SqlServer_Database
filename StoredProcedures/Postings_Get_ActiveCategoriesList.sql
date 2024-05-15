CREATE OR ALTER PROCEDURE [dbo].[Postings_Get_ActiveCategoriesList](
	@LanguageID INT = 2
)
AS

   

SELECT ISNULL((
	SELECT DISTINCT VPCPC2.ColumnId AS columnId
		, (
			SELECT DISTINCT VPCPC1.ParentCategoryName AS parentCategoryName
				, VPCPC1.ParentCategoryId AS parentCategoryId
				, VPCPC1.ParentRankID AS parentRankID
				, (
					SELECT VPCPC.ChildCategoryID AS childCategoryId
						, VPCPC.ChildCategoryName AS childCategoryName
						, VPCPC.ChildRankID AS childRankId
					FROM dbo.vw_Parent_Child_Postings_Categories AS VPCPC
					WHERE VPCPC.LanguageID = @LanguageID
						AND VPCPC.ParentCategoryID = VPCPC1.ParentCategoryID
					GROUP BY VPCPC.ChildCategoryID, VPCPC.ChildCategoryName, VPCPC.ChildRankID
					ORDER BY childRankId
					FOR JSON AUTO
				) AS childCategories
			FROM dbo.vw_Parent_Child_Postings_Categories AS VPCPC1
			WHERE VPCPC1.columnId = VPCPC2.columnId
			ORDER BY parentRankID
			FOR JSON AUTO
		) AS parentCategories
	FROM dbo.vw_Parent_Child_Postings_Categories AS VPCPC2
	FOR JSON PATH, ROOT('columns'), INCLUDE_NULL_VALUES
), '{"columns":[]}') AS jsonString;


GO

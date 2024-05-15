CREATE OR ALTER PROCEDURE [dbo].[Postings_Get_ListOfCategoriesInGeography](
	@IPAddress DECIMAL(38, 0)
	, @IpAddressProtocol TINYINT = 1
	, @LanguageID INT = 2
)
AS

DECLARE @TopCountryID INT
	, @TopStateID INT
	, @TopCityID INT;
	   
SELECT TOP 1 @TopCountryID = CountryID
	, @TopStateID = StateID
	, @TopCityID = CityID
FROM dbo.IPAddress_VS_Location WITH(NOLOCK)
WHERE @IPAddress BETWEEN FromIp AND ToIP
	AND IPAddressVersionID = @IpAddressProtocol;


IF @TopCityID IS NULL BEGIN

	DECLARE @IPAddressVersionsStr VARCHAR(10) = 
		CASE @IpAddressProtocol 
			WHEN 1 THEN 'v4' 
			WHEN 2 THEN 'v6' 
		END;

	EXEC dbo.LocationSearch_Get_LocationBasedOnIP
		@IPAddress = @IpAddress
		, @IPAddressVersion = @IPAddressVersionsStr
		, @CountryID = @TopCountryID OUTPUT
		, @StateID = @TopStateID OUTPUT
		, @CityID = @TopCityID OUTPUT;

END;

	   

SELECT ISNULL((
	SELECT DISTINCT VPCPC2.ColumnId AS columnId
		, (
			SELECT DISTINCT VPCPC1.ParentCategoryName AS parentCategoryName
				, VPCPC1.ParentCategoryId AS parentCategoryId
				, VPCPC1.ParentRankID AS parentRankID
				, (
					SELECT VPCPC.ChildCategoryID AS childCategoryId, VPCPC.ChildCategoryName AS childCategoryName
						, VPCPC.ChildRankID AS childRankId, COUNT(DISTINCT PC.PostingID) AS postings
					FROM dbo.Location_Cities_Latitude_Longitude AS LCLL_origin
					JOIN dbo.Location_Cities_Latitude_Longitude AS LCLL_reach ON 
						LCLL_origin.CityID = @TopCityID
						AND LCLL_origin.AvgLatitude BETWEEN LCLL_origin.AvgLatitudeLowerLimit1 AND LCLL_origin.AvgLatitudeUpperLimit1
						AND LCLL_origin.AvgLongitude BETWEEN LCLL_origin.AvgLongitudeLeftmostLimit1 AND LCLL_origin.AvgLongitudeRightmostLimit1
					JOIN dbo.Postings_Locations AS PL ON LCLL_reach.CityID = PL.CityID
					JOIN dbo.PostingsCategories AS PC ON PC.PostingID = PL.PostingID
					RIGHT JOIN dbo.vw_Parent_Child_Postings_Categories AS VPCPC ON PC.ChildCategoryID = VPCPC.ChildCategoryID
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





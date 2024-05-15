USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[GET_IPAddress_BasedOnCityName]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



IF OBJECT_ID(N'LocationSearch_Get_IPAddressBasedOnCityName', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.LocationSearch_Get_IPAddressBasedOnCityName AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[LocationSearch_Get_IPAddressBasedOnCityName] (
	@SearchCity NVARCHAR(100)
)
AS



DECLARE @IPAddressRangeGeographyID BIGINT;


SELECT @IPAddressRangeGeographyID = MIN(IPAddressRangeGeographyID)
FROM dbo.Location_Cities AS C WITH(NOLOCK)
INNER JOIN dbo.IPAddress_VS_Location AS IL WITH(NOLOCK) ON C.CityID = IL.CityID
WHERE C.FullCityName_State_Country LIKE '%' + @SearchCity + '%';



SELECT (
	SELECT CAST(FromIP AS VARCHAR) AS ipAddress
		, CASE IPAddressVersionID WHEN 1 THEN 'v4' ELSE 'v6' END AS ipAddressVersion
	FROM dbo.IPAddress_VS_Location WITH(NOLOCK)
	WHERE IPAddressRangeGeographyID = @IPAddressRangeGeographyID
	FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
) AS jsonString;



GO
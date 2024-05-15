USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[VISITOR_HashtagListStartingWithLetter_CheckIfExists_IfNot_CreateOne]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'Hashtags_Get_ListOfHashtagsForGeography', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.Hashtags_Get_ListOfHashtagsForGeography AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[Hashtags_Get_ListOfHashtagsForGeography](
	@IPAddress DECIMAL(38, 0)
	, @IpAddressProtocol TINYINT
	, @StartingLetter NVARCHAR(10) = NULL
	, @OnlyTopFive BIT = 0 --could be discontinued soon
)
AS


DECLARE @TopCountryID INT
	, @TopStateID INT
	, @TopCityID INT
	, @HashtagListID BIGINT
	, @Compute BIT = 0
	, @LastUpdatedDate SMALLDATETIME;
	   

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


SELECT ISNULL(
	(
		SELECT H.Hashtag AS hashtag, COUNT(DISTINCT PL.PostingID) AS relevance
		FROM dbo.IPAddress_VS_Location AS IL
		JOIN dbo.Location_Cities_Latitude_Longitude AS LCLL ON IL.CityID = LCLL.CityID
		JOIN dbo.Location_Cities_Latitude_Longitude AS BOUNDARIES ON 
			LCLL.AvgLatitude BETWEEN BOUNDARIES.[AvgLatitudeLowerLimit1] AND BOUNDARIES.[AvgLatitudeUpperLimit1]
			AND LCLL.AvgLongitude BETWEEN BOUNDARIES.[AvgLongitudeLeftmostLimit1] AND BOUNDARIES.[AvgLongitudeRightmostLimit1]
		JOIN dbo.Postings_Locations AS PL ON BOUNDARIES.CityID = PL.CityID
		JOIN dbo.HashtagsPostings AS HP ON PL.PostingID = HP.PostingID
		JOIN dbo.Hashtags AS H ON HP.HashtagID = H.HashtagID
		WHERE IL.CityID = @TopCityID
			AND PL.Active = 1
		GROUP BY H.Hashtag 
		ORDER BY H.Hashtag
		FOR JSON PATH, ROOT('hashtags')
	)
, '{"hashtags":[]}') AS jsonString;




GO
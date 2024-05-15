
CREATE OR ALTER PROC dbo.SuigenerisSearchCriteria_Get_HashtagsForUserSearchLocations
	@UserID BIGINT 
AS



SELECT H.HashtagID
	INTO #DONTUSETHESE
FROM dbo.User_SearchWords AS USW
JOIN dbo.SearchWords AS SW ON USW.SearchWordID = SW.SearchWordID
JOIN dbo.Hashtags AS H WITH(INDEX(IX_Hashtags_Hashtag)) ON SW.Word = H.Hashtag
WHERE USW.UserID = @UserID;



SELECT ISNULL((
	SELECT H.Hashtag as hashtag, COUNT(DISTINCT HP.PostingID) AS relevance
	FROM dbo.User_LocationsFollowed AS ULF
	JOIN dbo.Location_Cities_Latitude_Longitude AS LCLL ON ULF.CityID = LCLL.CityID
	JOIN dbo.Location_Cities_Latitude_Longitude AS BOUNDARIES ON 
		LCLL.AvgLatitude BETWEEN BOUNDARIES.[AvgLatitudeLowerLimit1] AND BOUNDARIES.[AvgLatitudeUpperLimit1]
		AND LCLL.AvgLongitude BETWEEN BOUNDARIES.[AvgLongitudeLeftmostLimit1] AND BOUNDARIES.[AvgLongitudeRightmostLimit1]
	JOIN dbo.Postings_Locations AS PL ON BOUNDARIES.CityID = PL.CityID
	JOIN dbo.HashtagsPostings AS HP ON PL.PostingID = HP.PostingID
	JOIN dbo.Hashtags AS H ON HP.HashtagID = H.HashtagID
	WHERE ULF.UserID = @UserID
		AND PL.Active = 1
		AND HP.HashtagID NOT IN (SELECT HashtagID FROM #DONTUSETHESE)  
	GROUP BY H.Hashtag
	FOR JSON PATH, ROOT('hashtags')
), '{"hashtags":[]}') AS jsonString;  




GO
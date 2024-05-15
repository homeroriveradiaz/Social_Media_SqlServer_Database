USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[User_ThisUser_ActivePostings]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID(N'Postings_Get_PostingsThatBelongToThisUser', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.Postings_Get_PostingsThatBelongToThisUser AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[Postings_Get_PostingsThatBelongToThisUser](
	@UserID BIGINT
	, @LanguageID INT
	, @BelowPostingID BIGINT = NULL
	, @IncludeThreads BIT = 0
)
AS


DECLARE @MediaURL VARCHAR(200) = dbo.fn_Get_Media_URL()
	, @Query VARCHAR(8000);

/*************************************************************************************************************************************
THIS IS THE MAIN QUERY MODEL. DEPENDING ON IF CONDITIONS, SOME PARTS COULD BE IGNORED


SELECT ISNULL((
	SELECT TOP 20 CAST(VP.PostingID AS VARCHAR) AS postingId, VP.PostingTitle AS postingTitle, VP.PostingMessage AS postingMessage
		, dbo.fnha_ui_how_long_since_posting(VP.PostDateTime, @LanguageID) AS postedOn
		, VP.Price AS price, VP.CurrencySymbol AS currencySymbol, VP.CurrencyAbbreviation AS currencyAbbreviation
		, @MediaURL + VP.Avatar AS avatar, CAST(VP.PostedByUserID AS VARCHAR) AS postedByUserId, VP.[Name] AS name
		, (ISNULL((
			SELECT @MediaURL + I.[Image] AS [image]
			FROM dbo.Postings_AttachedImages AS AI
			INNER JOIN dbo.Images AS I ON AI.ImageId = I.ImageId
			WHERE AI.PostingID = VP.PostingID
			FOR JSON AUTO
		), '[]')) AS images
		, (ISNULL((
			SELECT ULS.FullCityName_State_Country AS [location]
			FROM dbo.Postings_Locations AS PL
			INNER JOIN dbo.UserLocationsSearch AS ULS ON PL.CountryID = ULS.CountryID
				AND PL.StateID = ULS.StateID
				AND PL.CityID = ULS.CityID
			WHERE PL.PostingID = VP.PostingID
			FOR JSON AUTO
		), '[]')) as locations
		, CAST(					
			CASE WHEN EXISTS(
				SELECT TOP 1 1  
				FROM dbo.PostingsThreads AS PT
				LEFT JOIN dbo.Notifications_ForUserInterface AS NFUI ON NFUI.Value1 = PT.PostingThreadID
				WHERE PT.RootPostingID = VP.PostingID
					AND NFUI.UserID = VP.PostedByUserID
					AND NFUI.NotificationTypeID = 3
			) THEN 1 ELSE 0 END
		AS BIT) AS hasNotifications
		, (ISNULL((
			SELECT U.[Name] AS [name], @MediaURL + U.AvatarImageURL AS avatar
				, CAST(PT.PostingThreadID AS NVARCHAR) AS postingThreadId
				, (
					SELECT TOP (1) UPK.ShortenedNameFull
					FROM dbo.UsersPublicKey AS UPK 
					WHERE UPK.UserID = PT.RespondingUserID
					ORDER BY UPK.ShortenedNameID
				) AS userPublicKey
				, CAST(CASE WHEN EXISTS(
					SELECT TOP 1 1 
					FROM dbo.User_SavedPostings AS USP
					WHERE PT.RootPostingID = USP.PostingID
						AND USP.UserID = PT.RespondingUserID
				) THEN 1 ELSE 0 END AS BIT) AS isThreadActive
				, CAST(					
					CASE WHEN EXISTS(
						SELECT TOP 1 1
						FROM dbo.Notifications_ForUserInterface AS NFUI
						WHERE NFUI.UserID = @UserID
							AND NFUI.Value1 = PT.PostingThreadID
							AND NFUI.NotificationTypeID = 3
					) THEN 1 ELSE 0 END
				AS BIT) AS hasNotification
				, (
					SELECT CAST(PIT.PostingInThreadID AS NVARCHAR) AS postingInThreadId
						, CASE WHEN @UserID = PIT.PostedByUserID THEN 'poster' ELSE 'responder' END AS [by]
						, U1.[Name] AS [name]
						, @MediaURL + U1.AvatarImageURL AS avatar
						, dbo.fnha_ui_how_long_since_posting(PIT.PostDateTime, @LanguageID) AS [postedOn]
						, PIT.PostingMessage as [postingMessage]
						, (ISNULL((
							SELECT @MediaURL + I.[Image] AS [image]
							FROM dbo.PostingInThreadID_AttachedImages AS PITIM
							INNER JOIN dbo.Images AS I ON PITIM.ImageId = I.ImageId
							WHERE PITIM.PostingInThreadID = PIT.PostingInThreadID
							ORDER BY PITIM.PostingInThreadIDAttachedImagesID
							FOR JSON PATH
						), '[]')) as images
					FROM dbo.PostingsInThreads AS PIT
					INNER JOIN dbo.Users AS U1 ON PIT.PostedByUserID = U1.UserID
					WHERE PT.PostingThreadID = PIT.PostingThreadID
					ORDER BY PIT.PostingInThreadID
					FOR JSON PATH						
				) AS postingsInThread
			FROM dbo.PostingsThreads AS PT
			INNER JOIN dbo.Users AS U ON PT.RespondingUserID = U.UserID
			WHERE PT.RootPostingID = VP.PostingID
			FOR JSON PATH
		), '[]')) as threads
	FROM dbo.vw_postings_raw_data_for_search_lists AS VP
	WHERE (VP.PostingTypeID = 1
			AND VP.PostingActive = 1
			AND VP.PostingCensored = 0
			AND VP.PostingUserActive = 1
			AND VP.PostingUserCensored = 0			
		)
		AND VP.PostedByUserID = @UserID
		AND VP.PostingID < @BelowPostingID
	ORDER BY VP.PostingID DESC
	FOR JSON PATH, ROOT('postings'), INCLUDE_NULL_VALUES
), '{"postings":[]}') AS jsonString;

*************************************************************************************************************************************/


SET @Query = '
SELECT ISNULL(( 
	SELECT TOP 20 CAST(VP.PostingID AS VARCHAR) AS postingId, VP.PostingTitle AS postingTitle, VP.PostingMessage AS postingMessage 
		, dbo.fnha_ui_how_long_since_posting(VP.PostDateTime, ' + CAST(@LanguageID AS VARCHAR) +') AS postedOn 
		, VP.Price AS price, VP.CurrencySymbol AS currencySymbol, VP.CurrencyAbbreviation AS currencyAbbreviation 
		, ''' + @MediaURL + ''' + VP.Avatar AS avatar, CAST(VP.PostedByUserID AS VARCHAR) AS postedByUserId, VP.[Name] AS name 
		, (ISNULL(( 
			SELECT ''' + @MediaURL + ''' + I.[Image] AS [image] 
			FROM dbo.Postings_AttachedImages AS AI 
			INNER JOIN dbo.Images AS I ON AI.ImageId = I.ImageId 
			WHERE AI.PostingID = VP.PostingID 
			FOR JSON AUTO 
		), ''[]'')) AS images 
		, (ISNULL(( 
			SELECT ULS.FullCityName_State_Country AS [location] 
			FROM dbo.Postings_Locations AS PL 
			INNER JOIN dbo.UserLocationsSearch AS ULS ON PL.CountryID = ULS.CountryID 
				AND PL.StateID = ULS.StateID 
				AND PL.CityID = ULS.CityID 
			WHERE PL.PostingID = VP.PostingID 
			FOR JSON AUTO 
		), ''[]'')) as locations 
		, CAST(				 	
			CASE WHEN EXISTS( 
				SELECT TOP 1 1  
				FROM dbo.PostingsThreads AS PT 
				LEFT JOIN dbo.Notifications_ForUserInterface AS NFUI ON NFUI.Value1 = PT.PostingThreadID 
				WHERE PT.RootPostingID = VP.PostingID 
					AND NFUI.UserID = VP.PostedByUserID 
					AND NFUI.NotificationTypeID = 3 
			) THEN 1 ELSE 0 END 
		AS BIT) AS hasNotifications '
+ CASE WHEN @IncludeThreads = 1 THEN 
'		, (ISNULL(( 
			SELECT U.[Name] AS [name], ''' + @MediaURL + ''' + U.AvatarImageURL AS avatar 
				, CAST(PT.PostingThreadID AS NVARCHAR) AS postingThreadId
				, (
					SELECT TOP (1) UPK.ShortenedNameFull
					FROM dbo.UsersPublicKey AS UPK 
					WHERE UPK.UserID = PT.RespondingUserID
					ORDER BY UPK.ShortenedNameID
				) AS userPublicKey
				, CAST(CASE WHEN EXISTS(
					SELECT TOP 1 1 
					FROM dbo.User_SavedPostings AS USP
					WHERE PT.RootPostingID = USP.PostingID
						AND USP.UserID = PT.RespondingUserID
				) THEN 1 ELSE 0 END AS BIT) AS isThreadActive
				, CAST(					
					CASE WHEN EXISTS(
						SELECT TOP 1 1
						FROM dbo.Notifications_ForUserInterface AS NFUI
						WHERE NFUI.UserID = ' + CAST(@UserID AS VARCHAR) + '
							AND NFUI.Value1 = PT.PostingThreadID
							AND NFUI.NotificationTypeID = 3
					) THEN 1 ELSE 0 END
				AS BIT) AS hasNotification
				, ( 
					SELECT CAST(PIT.PostingInThreadID AS NVARCHAR) AS postingInThreadId 
						, CASE WHEN ' + CAST(@UserID AS VARCHAR) + ' = PIT.PostedByUserID THEN ''poster'' ELSE ''responder'' END AS [by] 
						, U1.[Name] AS [name] 
						, ''' + @MediaURL + ''' + U1.AvatarImageURL AS avatar 
						, dbo.fnha_ui_how_long_since_posting(PIT.PostDateTime, ' + CAST(@LanguageID AS VARCHAR) +') AS [postedOn] 
						, PIT.PostingMessage as [postingMessage] 
						, (ISNULL(( 
							SELECT ''' + @MediaURL + ''' + I.[Image] AS [image] 
							FROM dbo.PostingInThreadID_AttachedImages AS PITIM 
							INNER JOIN dbo.Images AS I ON PITIM.ImageId = I.ImageId 
							WHERE PITIM.PostingInThreadID = PIT.PostingInThreadID 
							ORDER BY PITIM.PostingInThreadIDAttachedImagesID 
							FOR JSON PATH 
						), ''[]'')) as images 
					FROM dbo.PostingsInThreads AS PIT 
					INNER JOIN dbo.Users AS U1 ON PIT.PostedByUserID = U1.UserID 
					WHERE PT.PostingThreadID = PIT.PostingThreadID 
					ORDER BY PIT.PostingInThreadID
					FOR JSON PATH	 					
				) AS postingsInThread 
			FROM dbo.PostingsThreads AS PT 
			INNER JOIN dbo.Users AS U ON PT.RespondingUserID = U.UserID 
			WHERE PT.RootPostingID = VP.PostingID 
			FOR JSON PATH 
		), ''[]'')) as threads '
ELSE '' END + 
'	FROM dbo.vw_postings_raw_data_for_search_lists AS VP 
	WHERE (VP.PostingTypeID = 1
			AND VP.PostingActive = 1
			AND VP.PostingCensored = 0
			AND VP.PostingUserActive = 1
			AND VP.PostingUserCensored = 0			
		)
		AND VP.PostedByUserID = ' + CAST(@UserID AS VARCHAR) + ' 
		' + CASE WHEN @BelowPostingID IS NOT NULL THEN ' AND VP.PostingID < ' + CAST(@BelowPostingID AS VARCHAR) ELSE '' END + ' 
	ORDER BY VP.PostingID DESC 
	FOR JSON PATH, ROOT(''postings''), INCLUDE_NULL_VALUES 
), ''{"postings":[]}'') AS jsonString; ';


EXEC(@Query);



GO
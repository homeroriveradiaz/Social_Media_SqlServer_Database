USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[User_ThisUser_GetPostingsThatWereSaved]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE OR ALTER PROCEDURE [dbo].[Postings_Get_ClippedPostings](
	@UserID BIGINT
	, @LanguageID INT
	, @IncludeThreads BIT = 0
	, @PostingID BIGINT = NULL
)
AS

DECLARE @MediaURL VARCHAR(200) = dbo.fn_Get_Media_URL();


IF (@IncludeThreads = 0) BEGIN

	SELECT ISNULL((
		SELECT CAST(VP.PostingID AS NVARCHAR) AS postingId, VP.PostingTitle AS postingTitle, VP.PostingMessage AS postingMessage
			, dbo.fnha_ui_how_long_since_posting(VP.PostDateTime, @LanguageID) AS postedOn
			, VP.Price AS price, VP.CurrencySymbol AS currencySymbol, VP.CurrencyAbbreviation AS currencyAbbreviation
			, @MediaURL + VP.Avatar AS avatar, VP.UserPublicKey AS userPublicKey, VP.[Name] AS [name]
			, CAST(CASE WHEN NFUI.NotificationID IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS [hasNotification]
			, CAST(NFUI.NotificationID AS NVARCHAR) AS notificationId
			, CAST(CASE WHEN VP.PostingActive = 0 OR VP.PostingCensored = 1 OR VP.PostingUserActive = 0 OR VP.PostingUserCensored = 1 THEN 0 ELSE 1 END AS BIT) AS postingAvailable
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
				INNER JOIN dbo.UserLocationsSearch  AS ULS ON PL.CountryID = ULS.CountryID
					AND PL.StateID = ULS.StateID
					AND PL.CityID = ULS.CityID
				WHERE PL.PostingID = VP.PostingID
				FOR JSON AUTO
			), '[]')) as locations
		FROM dbo.User_SavedPostings AS SP WITH(NOLOCK)
			INNER JOIN dbo.vw_postings_raw_data_for_search_lists AS VP ON SP.PostingID = VP.PostingID
			LEFT JOIN dbo.Notifications_ForUserInterface AS NFUI WITH(NOLOCK) ON NFUI.UserID = @UserID
				AND NFUI.NotificationTypeID = 4
				AND NFUI.Value1 = SP.PostingID
		WHERE SP.UserID = @UserID
			AND VP.PostingTypeID = 1
			AND VP.PostedByUserID <> @UserID
			AND VP.PostedByUserID NOT IN (SELECT BannedUserID FROM dbo.User_BannedUsers WITH(NOLOCK) WHERE UserID = @UserID)
			AND ISNULL(@PostingID, SP.PostingID) = SP.PostingID
		ORDER BY SP.FollowDate DESC
		FOR JSON PATH, ROOT('postings'), INCLUDE_NULL_VALUES
	), '{"postings":[]}') AS jsonString;

END ELSE BEGIN

	SELECT ISNULL((
		SELECT CAST(VP.PostingID AS NVARCHAR) AS postingId, VP.PostingTitle AS postingTitle, VP.PostingMessage AS postingMessage
			, dbo.fnha_ui_how_long_since_posting(VP.PostDateTime, @LanguageID) AS postedOn
			, VP.Price AS price, VP.CurrencySymbol AS currencySymbol, VP.CurrencyAbbreviation AS currencyAbbreviation
			, @MediaURL + VP.Avatar AS avatar, VP.UserPublicKey AS userPublicKey, VP.[Name] AS [name]
			, CAST(CASE WHEN NFUI.NotificationID IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS [hasNotification]
			, CAST(NFUI.NotificationID AS NVARCHAR) AS notificationId
			, CAST(CASE WHEN VP.PostingActive = 0 OR VP.PostingCensored = 1 OR VP.PostingUserActive = 0 OR VP.PostingUserCensored = 1 THEN 0 ELSE 1 END AS BIT) AS postingAvailable
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
				INNER JOIN dbo.UserLocationsSearch  AS ULS ON PL.CountryID = ULS.CountryID
					AND PL.StateID = ULS.StateID
					AND PL.CityID = ULS.CityID
				WHERE PL.PostingID = VP.PostingID
				FOR JSON AUTO
			), '[]')) as locations
			, (ISNULL((
				SELECT 
					CAST(PIT.PostingInThreadID AS NVARCHAR) AS postingInThreadId
					, CASE WHEN @UserID = PIT.PostedByUserID THEN 'responder' ELSE 'poster' END AS [by]
					, U.[Name] AS [name]
					, @MediaURL + U.AvatarImageURL AS avatar
					, dbo.fnha_ui_how_long_since_posting(PIT.PostDateTime, @LanguageID) AS [postedOn]
					, PIT.PostingMessage as [postingMessage]
					, (ISNULL((
							SELECT @MediaURL + I.[Image] AS [image]
							FROM dbo.PostingInThreadID_AttachedImages AS PITIM
							INNER JOIN dbo.Images AS I ON PITIM.ImageId = I.ImageId
							WHERE PITIM.PostingInThreadID = PIT.PostingInThreadID
							ORDER BY PITIM.PostingInThreadIDAttachedImagesID
							FOR JSON PATH
						), '[]')
					) as images
				FROM dbo.PostingsThreads AS PT
				INNER JOIN dbo.PostingsInThreads AS PIT ON PT.PostingThreadID = PIT.PostingThreadID
				INNER JOIN dbo.Users AS U ON PIT.PostedByUserID = U.UserID
				WHERE PT.RootPostingID = SP.PostingID
					AND PT.RespondingUserID = @UserID
				FOR JSON PATH
			), '[]')) as thread
		FROM dbo.User_SavedPostings AS SP WITH(NOLOCK)
			INNER JOIN dbo.vw_postings_raw_data_for_search_lists AS VP ON SP.PostingID = VP.PostingID
			LEFT JOIN dbo.Notifications_ForUserInterface AS NFUI WITH(NOLOCK) ON NFUI.UserID = @UserID
				AND NFUI.NotificationTypeID = 4
				AND NFUI.Value1 = SP.PostingID
		WHERE SP.UserID = @UserID
			AND VP.PostingTypeID = 1
			AND VP.PostedByUserID <> @UserID
			AND VP.PostedByUserID NOT IN (SELECT BannedUserID FROM dbo.User_BannedUsers WITH(NOLOCK) WHERE UserID = @UserID)
			AND ISNULL(@PostingID, SP.PostingID) = SP.PostingID
		ORDER BY SP.FollowDate DESC
		FOR JSON PATH, ROOT('postings'), INCLUDE_NULL_VALUES
	), '{"postings":[]}') AS jsonString;


END;

GO
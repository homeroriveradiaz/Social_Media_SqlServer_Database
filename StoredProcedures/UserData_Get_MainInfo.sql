USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[UserData_MainDescriptionInfo]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.UserData_Get_MainInfo', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserData_Get_MainInfo AS SELECT 1;');
END;
GO


/*******************************************************************************
RETURNS MAIN PROFILE INFO FOR A USER

@ShowingToOwnUser DETERMINES WHETHER SOME COLUMNS SHOULD BE RETURNED OR NOT.

EXAMPLE: WHEN SHOWING THIS TO ANOTHER USER, THESE COLUMNS ARE OF NO USE:
		U.SendEmailWhenTheyReplyToMyReplies,
		U.SendEmailWhenTheyReplyToMyPostings,
		U.SendEmailWithNewsletter

*******************************************************************************/
ALTER PROC dbo.UserData_Get_MainInfo(
	@UserID BIGINT = NULL
	, @IsPublic BIT = 0
	, @UserPublicKey NVARCHAR(200) = NULL
) AS


DECLARE @MediaURL VARCHAR(500) = dbo.fn_Get_Media_URL();



IF (@IsPublic = 0) BEGIN

	SELECT ISNULL((
		SELECT U.Name AS name, U.Slogan AS slogan, U.BusinessDescription AS businessDescription, 
			ci.City + ', ' + s.StateAbbreviation + ', ' + c.CountryAbbreviation AS mainLocation,
			@MediaURL + U.AvatarImageURL AS avatarImageURL, @MediaURL + U.BackgroundImageURL AS backgroundImageURL,
			U.SendEmailWhenTheyReplyToMyReplies AS sendEmailWhenTheyReplyToMyReplies,
			U.SendEmailWhenTheyReplyToMyPostings AS sendEmailWhenTheyReplyToMyPostings,
			U.SendEmailWithNewsletter AS sendEmailWithNewsletter,
			UPK.ShortenedNameFull AS publicUserKey,
			U.DefaultCurrencyId AS defaultCurrencyId,
			(
				SELECT COUNT(*)
				FROM dbo.User_UsersFollowed AS UF WITH(NOLOCK)
				WHERE UF.UserIDFollowed = U.UserID
			) AS countOfFollowers 
		FROM dbo.Users AS U WITH(NOLOCK)
		INNER JOIN dbo.UsersPublicKey AS UPK WITH(NOLOCK) ON U.UserID = UPK.UserID
		LEFT JOIN dbo.Location_Countries AS C WITH(NOLOCK) ON u.BaseCountryID = c.CountryID
		LEFT JOIN dbo.Location_States AS S WITH(NOLOCK) ON u.BaseStateID = s.StateID
		LEFT JOIN dbo.Location_Cities AS CI WITH(NOLOCK) ON u.BaseCityID = ci.CityId
		WHERE U.UserID = @UserID
			AND U.Active = 1
			AND U.Censored = 0
		FOR JSON PATH, ROOT('userInfo')
	), '{"userInfo":[]}') AS jsonString;

END; ELSE BEGIN

	DECLARE @UID BIGINT = NULL;

	SELECT @UID = UserID
	FROM [dbo].[UsersPublicKey]
	WHERE [ShortenedNameFull] = @UserPublicKey;
		
	IF (@UID IS NOT NULL) BEGIN
		SELECT ISNULL((
			SELECT U.Name AS name, U.Slogan AS slogan, U.BusinessDescription AS businessDescription, 
				ci.City + ', ' + s.StateAbbreviation + ', ' + c.CountryAbbreviation AS mainLocation,
				@MediaURL + U.AvatarImageURL AS avatarImageURL, @MediaURL + U.BackgroundImageURL AS backgroundImageURL,
				(
					SELECT COUNT(*)
					FROM dbo.User_UsersFollowed AS UF WITH(NOLOCK)
					WHERE UF.UserIDFollowed = U.UserID
				) AS countOfFollowers
			FROM dbo.Users AS U WITH(NOLOCK)
			LEFT JOIN dbo.Location_Countries AS C WITH(NOLOCK) ON u.BaseCountryID = c.CountryID
			LEFT JOIN dbo.Location_States AS S WITH(NOLOCK) ON u.BaseStateID = s.StateID
			LEFT JOIN dbo.Location_Cities AS CI WITH(NOLOCK) ON u.BaseCityID = ci.CityId
			WHERE U.UserID = @UID
				AND U.Active = 1
				AND U.Censored = 0
			FOR JSON PATH, ROOT('userInfo')
		), '{"userInfo":[]}') AS jsonString;
	END; ELSE BEGIN
		RAISERROR(N'Bad attempt to obtain use data recorded', 16, 1);
	END;

END;


GO

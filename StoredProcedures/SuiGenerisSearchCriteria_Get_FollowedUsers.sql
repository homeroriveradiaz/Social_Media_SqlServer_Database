USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[UsersFollowed_GetUsersFollowed]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'SuiGenerisSearchCriteria_Get_FollowedUsers', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.SuiGenerisSearchCriteria_Get_FollowedUsers AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[SuiGenerisSearchCriteria_Get_FollowedUsers](
	@UserID BIGINT
)
AS

DECLARE @MediaURL VARCHAR(200) = dbo.fn_Get_Media_URL();

DELETE dbo.Notifications_ForUserInterface
WHERE UserID = @UserID 
	AND NotificationTypeID = 1;

SELECT ISNULL((
	SELECT U.[Name] AS name
		, @MediaURL + U.AvatarImageURL AS avatar
		, UF.IsMute AS isMute
		, (
			SELECT TOP (1) UPK.ShortenedNameFull
			FROM dbo.UsersPublicKey AS UPK 
			WHERE UPK.UserID = U.UserID
			ORDER BY UPK.ShortenedNameID DESC
		) AS userPublicKey
		, U.Slogan AS slogan
	FROM dbo.User_UsersFollowed AS UF WITH(NOLOCK)
	INNER JOIN dbo.Users AS U WITH(NOLOCK) ON uf.UserIDFollowed = u.UserID
	--INNER JOIN dbo.UsersPublicKey AS UPK WITH(NOLOCK) ON u.UserID = upk.UserID
	WHERE UF.UserID = @UserID
		AND U.Active = 1
		AND U.Censored = 0
	ORDER BY U.[Name]
	FOR JSON PATH, ROOT('usersFollowed'), INCLUDE_NULL_VALUES
	), '{"usersFollowed":[]}') AS jsonString;


GO
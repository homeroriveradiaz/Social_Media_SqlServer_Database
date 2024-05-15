USE ReadWrite_Prod;
GO

CREATE OR ALTER PROCEDURE [dbo].[OtherUsefulItems_Get_ListOfRecommendedUsers] (
	@UserID BIGINT = NULL --only necessary when, as a user, we are visiting profile. This will exclude ourselves from the recommended users list.
	, @UserPublicKey NVARCHAR(200) --public key of curre profile being explored
)
AS


DECLARE @UID BIGINT = NULL
	, @MediaURL VARCHAR(500) = dbo.fn_Get_Media_URL();

SELECT @UID = UserID
FROM [dbo].[UsersPublicKey]
WHERE [ShortenedNameFull] = @UserPublicKey;


IF (@UserID IS NOT NULL) BEGIN
	
	SELECT ISNULL((
		SELECT TOP 8 UFD.UserIDFollowed AS userId, @MediaURL + U.AvatarImageURL AS avatar, U.Name AS name
			, COUNT(DISTINCT UFB.UserID) AS totalFollowers, U.Slogan AS slogan
		FROM dbo.User_UsersFollowed AS UFB WITH(NOLOCK)
		INNER JOIN dbo.User_UsersFollowed AS UFD WITH(NOLOCK) ON UFB.UserID = UFD.UserID
		INNER JOIN dbo.Users AS U WITH(NOLOCK) ON UFD.UserIDFollowed = U.UserID 
			AND U.Active = 1 AND U.Censored = 0
		WHERE UFB.UserIDFollowed = @UID
			AND UFD.UserIDFollowed NOT IN (@UID, @UserID)
			AND UFD.UserIDFollowed NOT IN (
				SELECT UserIDFollowed 
				FROM dbo.User_UsersFollowed WITH(NOLOCK)
				WHERE UserID = @UserID
			)
		GROUP BY UFD.UserIDFollowed, U.AvatarImageURL, U.Name, U.Slogan
		ORDER BY TotalFollowers DESC
		FOR JSON PATH, ROOT('users')
	), '{"users":[]}') AS jsonString;

END; ELSE BEGIN
	
	SELECT ISNULL((
		SELECT TOP 8 UFD.UserIDFollowed AS userId, @MediaURL + U.AvatarImageURL AS avatar, U.Name AS name
			, COUNT(DISTINCT UFB.UserID) AS totalFollowers, U.Slogan AS slogan
		FROM dbo.User_UsersFollowed AS UFB WITH(NOLOCK)
		INNER JOIN dbo.User_UsersFollowed AS UFD WITH(NOLOCK) ON UFB.UserID = UFD.UserID
		INNER JOIN dbo.Users AS U WITH(NOLOCK) ON UFD.UserIDFollowed = U.UserID
			AND U.Active = 1 AND U.Censored = 0
		WHERE UFB.UserIDFollowed = @UID
			AND UFD.UserIDFollowed <> @UID
		GROUP BY UFD.UserIDFollowed, U.AvatarImageURL, U.Name, U.Slogan
		ORDER BY TotalFollowers DESC
		FOR JSON PATH, ROOT('users')
	), '{"users":[]}') AS jsonString;

END;



GO
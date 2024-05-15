USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Profile_GetWebSites]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.UserData_Get_Websites', N'P') IS NULL BEGIN
	EXEC('CREATE PROC dbo.UserData_Get_Websites AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[UserData_Get_Websites](
	@UserID BIGINT = NULL
	, @IsPublic BIT = 0
	, @UserPublicKey NVARCHAR(200) = NULL
)
AS



IF (@IsPublic = 0) BEGIN

	SELECT ISNULL((
		SELECT CAST(WebsiteID AS VARCHAR) AS websiteId, Website AS website
		FROM dbo.Websites WITH(NOLOCK)
		WHERE UserID = @UserID
			AND Active = 1
		ORDER BY WebsiteID ASC
		FOR JSON PATH, ROOT('websites')
	), '{"websites":[]}') AS jsonString;

END; ELSE BEGIN

	DECLARE @UID BIGINT = NULL;

	SELECT @UID = UserID
	FROM [dbo].[UsersPublicKey]
	WHERE [ShortenedNameFull] = @UserPublicKey;
		
	IF (@UID IS NOT NULL) BEGIN
		SELECT ISNULL((
			SELECT Website AS website
			FROM dbo.Websites WITH(NOLOCK)
			WHERE UserID = @UID
				AND Active = 1
			ORDER BY WebsiteID ASC
			FOR JSON PATH, ROOT('websites')
		), '{"websites":[]}') AS jsonString;
	END; ELSE BEGIN
		RAISERROR(N'Bad attempt to obtain use data recorded', 16, 1);
	END;

END;




GO
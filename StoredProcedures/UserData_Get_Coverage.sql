USE ReadWrite_Prod;
GO


/****** Object:  StoredProcedure [dbo].[Profile_GetCoverage]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID(N'dbo.UserData_Get_Coverage', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserData_Get_Coverage AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[UserData_Get_Coverage](
	@UserID BIGINT = NULL
	, @LanguageID INT = 1
	, @IsPublic BIT = 0
	, @UserPublicKey NVARCHAR(200) = NULL
)
AS


IF (@IsPublic = 0) BEGIN

	SELECT ISNULL((
		SELECT CAST(C.CoverageID AS VARCHAR) AS coverageId
			, CASE WHEN @LanguageID = 1 THEN --English
					CASE WHEN C.StateID = -1 THEN 'all ' + CO.Country
						WHEN C.CityID = -1 THEN 'all ' + S.[State] + ', ' + CO.CountryAbbreviation
						ELSE CI.City + ', ' + S.StateAbbreviation + ', ' + CO.CountryAbbreviation
					END
				WHEN @LanguageID = 2 THEN --Spanish
					CASE WHEN C.StateID = -1 THEN 'todo ' + CO.Country
						WHEN C.CityID = -1 THEN 'todo ' + S.[State] + ', ' + CO.CountryAbbreviation
						ELSE CI.City + ', ' + S.StateAbbreviation + ', ' + CO.CountryAbbreviation
					END
			END AS coverage
		FROM dbo.Coverage AS C WITH(NOLOCK)
		INNER JOIN dbo.Location_Countries AS CO WITH(NOLOCK) ON C.CountryID = CO.CountryID
		LEFT JOIN dbo.Location_States AS S WITH(NOLOCK) ON C.StateID = S.StateID
		LEFT JOIN dbo.Location_Cities AS CI WITH(NOLOCK) ON C.CityID = CI.CityID
		WHERE C.UserID = @UserID
			AND C.Active = 1
		ORDER BY CO.Country ASC
		, S.[State] ASC
		, CI.City ASC
		FOR JSON PATH, ROOT('businessCoverage')
	), '{"businessCoverage":[]}') AS jsonString;

END; ELSE BEGIN

	DECLARE @UID BIGINT = NULL;

	SELECT @UID = UserID
	FROM [dbo].[UsersPublicKey]
	WHERE [ShortenedNameFull] = @UserPublicKey;
		
	IF (@UID IS NOT NULL) BEGIN
		SELECT ISNULL((
			SELECT CASE WHEN @LanguageID = 1 THEN --English
						CASE WHEN C.StateID = -1 THEN 'all ' + CO.Country
							WHEN C.CityID = -1 THEN 'all ' + S.[State] + ', ' + CO.CountryAbbreviation
							ELSE CI.City + ', ' + S.StateAbbreviation + ', ' + CO.CountryAbbreviation
						END
					WHEN @LanguageID = 2 THEN --Spanish
						CASE WHEN C.StateID = -1 THEN 'todo ' + CO.Country
							WHEN C.CityID = -1 THEN 'todo ' + S.[State] + ', ' + CO.CountryAbbreviation
							ELSE CI.City + ', ' + S.StateAbbreviation + ', ' + CO.CountryAbbreviation
						END
				END AS coverage
			FROM dbo.Coverage AS C WITH(NOLOCK)
			INNER JOIN dbo.Location_Countries AS CO WITH(NOLOCK) ON C.CountryID = CO.CountryID
			LEFT JOIN dbo.Location_States AS S WITH(NOLOCK) ON C.StateID = S.StateID
			LEFT JOIN dbo.Location_Cities AS CI WITH(NOLOCK) ON C.CityID = CI.CityID
			WHERE C.UserID = @UID
				AND C.Active = 1
			ORDER BY CO.Country ASC
			, S.[State] ASC
			, CI.City ASC
			FOR JSON PATH, ROOT('businessCoverage')
		), '{"businessCoverage":[]}') AS jsonString;
	END; ELSE BEGIN
		RAISERROR(N'Bad attempt to obtain use data recorded', 16, 1);
	END;

END;





GO




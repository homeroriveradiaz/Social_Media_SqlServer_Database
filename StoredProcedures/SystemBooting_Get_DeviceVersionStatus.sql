USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[GET_DeviceVersionStatus]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'SystemBooting_Get_DeviceVersionStatus', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.SystemBooting_Get_DeviceVersionStatus AS SELECT 1;');
END;
GO

ALTER PROC [dbo].[SystemBooting_Get_DeviceVersionStatus] (
	@DeviceID INT
	, @DeviceVersionID INT
	, @LanguageID INT
) AS



IF EXISTS(
	SELECT 1
	FROM dbo.DevicesVersionServices AS V WITH(NOLOCK)
	LEFT JOIN dbo.DevicesVersionServiceMessages AS M WITH(NOLOCK) ON V.VersionServiceID = M.VersionServiceID 
		AND M.LanguageID = @LanguageID 
	WHERE V.DeviceID = @DeviceID 
		AND V.DeviceVersionID = @DeviceVersionID
) BEGIN

	SELECT (
		SELECT CAST(1 AS BIT) AS [supported], V.IsToBeDeprecated AS isToBeDeprecated
			, V.IsDeprecated AS isDeprecated, ISNULL(M.ServiceMessage, 'ok') AS serviceMessage
		FROM dbo.DevicesVersionServices AS V WITH(NOLOCK)
		LEFT JOIN dbo.DevicesVersionServiceMessages AS M WITH(NOLOCK) ON V.VersionServiceID = M.VersionServiceID 
			AND M.LanguageID = @LanguageID
		WHERE V.DeviceID = @DeviceID
			AND V.DeviceVersionID = @DeviceVersionID
		FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
	) AS jsonString;


END; ELSE BEGIN

	SELECT (
		SELECT CAST(0 AS BIT) AS [supported], CAST(NULL AS BIT) AS isToBeDeprecated
			, CAST(NULL AS BIT) AS isDeprecated, CAST(NULL AS NVARCHAR(5)) AS serviceMessage
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
	) AS jsonString;
	
END;


GO
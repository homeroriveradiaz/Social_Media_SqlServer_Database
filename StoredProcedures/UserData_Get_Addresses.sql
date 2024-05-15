USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Profile_GetAddresses]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID(N'dbo.UserData_Get_Addresses', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserData_Get_Addresses AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[UserData_Get_Addresses] (
	@UserID BIGINT = NULL
	, @IsPublic BIT = 0
	, @UserPublicKey NVARCHAR(200) = NULL
)
AS


IF (@IsPublic = 0) BEGIN

	SELECT ISNULL((
		SELECT CAST(AddressID AS VARCHAR) AS addressId, [Address] AS [address]
		FROM dbo.Addresses WITH(NOLOCK)
		WHERE UserID = @UserID
			AND Active = 1
		FOR JSON PATH, ROOT('addresses')
	), '{"addresses":[]}') AS jsonString;

END; ELSE BEGIN

	DECLARE @UID BIGINT = NULL;

	SELECT @UID = UserID
	FROM [dbo].[UsersPublicKey]
	WHERE [ShortenedNameFull] = @UserPublicKey;
		
	IF (@UID IS NOT NULL) BEGIN
		SELECT ISNULL((
			SELECT [Address] AS [address]
			FROM dbo.Addresses WITH(NOLOCK)
			WHERE UserID = @UID
				AND Active = 1
			FOR JSON PATH, ROOT('addresses')
		), '{"addresses":[]}') AS jsonString;
	END; ELSE BEGIN
		RAISERROR(N'Bad attempt to obtain use data recorded', 16, 1);
	END;

END;


GO
USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[UserPublicKey_GetUserID]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'UserPublicKey_Get_Validation', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserPublicKey_Get_Validation AS SELECT 1;');
END;
GO


ALTER PROC [dbo].[UserPublicKey_Get_Validation] (
	@UserPublicKey NVARCHAR(200)
)
AS

IF EXISTS(
	SELECT 1
	FROM dbo.UsersPublicKey AS UPK WITH(NOLOCK)
	INNER JOIN dbo.Users AS U WITH(NOLOCK) ON UPK.UserID = U.UserID 
	WHERE UPK.ShortenedNameFull = @UserPublicKey
		AND U.Active = 1
		AND U.Censored = 0
) BEGIN
	SELECT (
		SELECT CAST(1 AS BIT) AS valid
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
	) AS jsonString;
END; ELSE BEGIN
	RAISERROR(N'Bad attempt to obtain use data recorded', 16, 1);
END;

GO
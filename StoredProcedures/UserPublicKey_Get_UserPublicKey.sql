USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[UserPublicKey_GetBasedOnUserID]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'UserPublicKey_Get_UserPublicKey', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserPublicKey_Get_UserPublicKey AS SELECT 1;');
END;
GO

ALTER PROC [dbo].[UserPublicKey_Get_UserPublicKey] (
	@UserID BIGINT
)
AS


DECLARE @UserPublicKey AS VARCHAR(100);

SELECT @UserPublicKey = ShortenedNameFull
FROM [dbo].[UsersPublicKey] AS UPK WITH(NOLOCK)
INNER JOIN dbo.Users AS U WITH(NOLOCK) ON UPK.UserID = U.UserID
WHERE UPK.UserID = @UserID
	AND U.Active = 1
	AND U.Censored = 0;


SELECT (
	SELECT @UserPublicKey AS userPublicKey
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
) AS jsonString;


GO
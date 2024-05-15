USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[LostPasswordTokens_VerifyTokenIsValid]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID(N'LostPassword_Verify_TokenIsValid', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.LostPassword_Verify_TokenIsValid AS SELECT 1;');
END;
GO


ALTER PROC [dbo].[LostPassword_Verify_TokenIsValid] (
	@UserID BIGINT
	, @Token NVARCHAR(100)
) AS 


DECLARE @Valid BIT = 0

IF EXISTS(SELECT 1 FROM dbo.LostPasswordTokens WITH(NOLOCK) WHERE UserID = @UserID AND Token = @Token AND ExpirationDateTime > GETUTCDATE()) BEGIN
	SET @Valid = 1;

END;

SELECT @Valid AS Valid;



GO



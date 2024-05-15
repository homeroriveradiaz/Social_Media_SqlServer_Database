USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[LostPasswordTokens_RemoveExpired]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'LostPassword_Delete_ExpiredTokens', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.LostPassword_Delete_ExpiredTokens AS SELECT 1;');
END;
GO

ALTER PROC [dbo].[LostPassword_Delete_ExpiredTokens] 
AS

SET NOCOUNT ON;

DECLARE @Expiration DATETIME = GETUTCDATE();

DELETE dbo.LostPasswordTokens
WHERE ExpirationDateTime < @Expiration;


GO
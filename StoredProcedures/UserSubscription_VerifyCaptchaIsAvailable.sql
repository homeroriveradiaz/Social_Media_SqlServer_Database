USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[CaptchaIsAvailable]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.UserSubscription_VerifyCaptchaIsAvailable', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserSubscription_VerifyCaptchaIsAvailable AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[UserSubscription_VerifyCaptchaIsAvailable](
	@CaptchaID BIGINT,
	@UserID BIGINT
)
AS


DECLARE @Exists AS BIT = 0;

IF EXISTS(SELECT 1 FROM dbo.CaptchaUserRelationship WITH(NOLOCK) WHERE CaptchaID = @CaptchaID AND UserID = @UserID AND Identified = 0) BEGIN
	SET @Exists = 1;
END;

SELECT @Exists AS [Exists];



GO
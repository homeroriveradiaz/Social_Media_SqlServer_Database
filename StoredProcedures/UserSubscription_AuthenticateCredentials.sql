USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Subscriber_AuthenticateCredentials]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.UserSubscription_AuthenticateCredentials', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserSubscription_AuthenticateCredentials AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[UserSubscription_AuthenticateCredentials] (
	@UserID BIGINT,
	@NewUserToken NVARCHAR(100)
)
AS


DECLARE @Exists BIT = 0;

IF EXISTS(SELECT 1 FROM dbo.NewUserTokens WITH(NOLOCK) WHERE UserID = @UserID AND Token = @NewUserToken) BEGIN
	SET @Exists = 1;
END;


SELECT @Exists AS [Exists];



GO
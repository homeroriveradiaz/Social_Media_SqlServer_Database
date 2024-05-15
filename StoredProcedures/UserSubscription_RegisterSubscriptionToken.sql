USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Subscriber_RegisterNewUserToken]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.UserSubscription_RegisterSubscriptionToken', N'P') IS NULL BEGIN
	EXEC('CREATE PROC dbo.UserSubscription_RegisterSubscriptionToken AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[UserSubscription_RegisterSubscriptionToken] (
	@UserID BIGINT,
	@Token NVARCHAR(100)
)
AS


IF EXISTS(SELECT 1 FROM dbo.NewUserTokens WITH(NOLOCK) WHERE UserID = @UserID) BEGIN
	RETURN;
END; ELSE BEGIN
	INSERT INTO dbo.NewUserTokens 
	VALUES (@UserID, @Token);
END;



GO
USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Subscriber_TrySubscribeUser_Step1]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID(N'dbo.UserSubscription_ReserveUsernameAndPassword', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserSubscription_ReserveUsernameAndPassword AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[UserSubscription_ReserveUsernameAndPassword](
	@Username NVARCHAR(100)
	, @Password NVARCHAR(100)
)
AS



DECLARE @NewUserID BIGINT = -9000000000000000001;


IF NOT EXISTS(SELECT 1 FROM dbo.Users WITH(NOLOCK) WHERE Username = @Username) BEGIN

	INSERT INTO dbo.Users(Username, [Password], DateCreated, LastVisit, Active, Censored) 
	VALUES (@Username, @Password, GETDATE(), GETDATE(), 0, 0);

	SELECT @NewUserID = SCOPE_IDENTITY();

END;


SELECT @NewUserID AS newUserId;




GO
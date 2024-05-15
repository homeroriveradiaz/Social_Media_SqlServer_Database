USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Subscriber_VerifyIfEmailIsDuplicate]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.UserSubscription_CheckIfEmailExistsAlready', N'P') IS NULL BEGIN
	EXEC('CREATE PROC dbo.UserSubscription_CheckIfEmailExistsAlready AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[UserSubscription_CheckIfEmailExistsAlready](
	@Email NVARCHAR(100)
)
AS


DECLARE @EmailExists BIT = 0;

IF EXISTS(SELECT 1 FROM dbo.Users WITH(NOLOCK) WHERE ContactEmail = @Email) BEGIN
	SET @EmailExists = 1;
END;

SELECT @EmailExists AS [EmailAlreadyExists];



GO


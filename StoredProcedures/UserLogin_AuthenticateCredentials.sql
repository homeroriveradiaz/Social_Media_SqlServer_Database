USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Login_AuthenticateCredentials]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO


IF OBJECT_ID(N'dbo.UserLogin_AuthenticateCredentials', N'P') IS NULL BEGIN
	EXEC('CREATE PROC dbo.UserLogin_AuthenticateCredentials AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[UserLogin_AuthenticateCredentials](
	@SessionToken NVARCHAR(500)
	, @UserID BIGINT
	, @IPAddress DECIMAL(35, 0)
	, @DeviceID INT
)
AS

DECLARE @Valid BIT = 0;

IF EXISTS(SELECT * FROM dbo.[Sessions] WHERE SessionToken = @SessionToken AND UserID = @UserID AND FromIPAddress = @IPAddress AND DeviceID = @DeviceID) BEGIN
	
	SET @Valid = 1;
	
	UPDATE dbo.Users
	SET LastVisit = GETDATE()
	WHERE UserID = @UserID;
	
END;

SELECT @Valid AS Valid;



GO
USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Login_CreateNewSession]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.UserLogin_CreateNewSession', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserLogin_CreateNewSession AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[UserLogin_CreateNewSession](
	@UserID BIGINT,
	@Session NVARCHAR(500),
	@IPAddress DECIMAL(35, 0),
	@IPAddressVersionID TINYINT,
	@DeviceID INT
)
AS


DELETE dbo.[Sessions]
WHERE UserId = @UserID
	AND DeviceID = @DeviceID;


INSERT INTO dbo.[Sessions] (UserID, SessionToken, LastInteractionDate, FromIPAddress, IPAddressVersionID, DeviceID)
VALUES (@UserID,@Session,GETDATE(),@IPAddress, @IPAddressVersionID, @DeviceID);


SELECT LastVisitingSectionID
FROM dbo.Users
WHERE UserID = @UserID;


GO
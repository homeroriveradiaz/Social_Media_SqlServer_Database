USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Logout_AuthenticateCredentials]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'UserLogin_DeleteSession', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserLogin_DeleteSession AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[UserLogin_DeleteSession]
(
	@SessionToken NVARCHAR(500)
	, @UserID BIGINT 
	, @IPAddress  DECIMAL(35, 0) 
	, @DeviceID INT
)
AS


DECLARE @RowsAffected INT, @Deleted BIT;


DELETE dbo.[Sessions]
WHERE SessionToken = @SessionToken 
	AND UserID = @UserID 
	AND FromIPAddress = @IPAddress
	AND DeviceID = @DeviceID;


SET @RowsAffected = @@ROWCOUNT;


IF (@RowsAffected = 1) BEGIN
	SET @Deleted = 1;
END; ELSE BEGIN
	SET @Deleted = 0;
END;


SELECT @Deleted AS Deleted;



GO
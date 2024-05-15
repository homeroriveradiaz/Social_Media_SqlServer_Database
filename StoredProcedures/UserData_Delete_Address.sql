USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Profile_GetAddresses]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID(N'dbo.UserData_Delete_Address', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserData_Delete_Address AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[UserData_Delete_Address] (
	@UserID BIGINT
	, @AddressID BIGINT
)
AS



UPDATE dbo.Addresses
SET Active = 0
WHERE UserID = @UserID
	AND AddressID = @AddressID;






GO
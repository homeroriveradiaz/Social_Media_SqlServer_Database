USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Profile_GetAddresses]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID(N'dbo.UserData_Add_Address', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserData_Add_Address AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[UserData_Add_Address] (
	@UserID BIGINT
	, @Address NVARCHAR(100)
)
AS



DECLARE @AddressID BIGINT;


INSERT INTO dbo.Addresses(UserID, DateCreated, [Address], Active)
VALUES (@UserID, GETDATE(), @Address, 1);


SET @AddressID = SCOPE_IDENTITY();


SELECT (
	SELECT CAST(@AddressID AS VARCHAR) AS addressId
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
) AS jsonString;



GO
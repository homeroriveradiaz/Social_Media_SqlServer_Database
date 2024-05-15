USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Profile_GetPhoneNumbers]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.UserData_Add_PhoneNumber', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserData_Add_PhoneNumber AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[UserData_Add_PhoneNumber](
	@UserID BIGINT
	, @PhoneNumber NVARCHAR(20)
)
AS


DECLARE @PhoneNumberID BIGINT;

INSERT INTO dbo.PhoneNumbers(UserID, DateCreated, PhoneNumber, Active)
VALUES (@UserID, GETDATE(), @PhoneNumber, 1);


SET @PhoneNumberID = SCOPE_IDENTITY();


SELECT (
	SELECT CAST(@PhoneNumberID AS VARCHAR) AS phoneNumberId
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
) AS jsonString;



GO
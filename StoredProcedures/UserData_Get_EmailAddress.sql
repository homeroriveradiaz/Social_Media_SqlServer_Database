USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[User_GetEmailAddress]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'UserData_Get_EmailAddress', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserData_Get_EmailAddress AS SELECT 1;');
END;
GO

ALTER PROC [dbo].[UserData_Get_EmailAddress](
	@UserID BIGINT
) AS 


SELECT (
	SELECT ContactEmail AS contactEmail
	FROM dbo.Users WITH(NOLOCK)
	WHERE UserID = @UserID
	FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
) AS jsonString;



GO
USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Profile_GetWebSites]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.UserData_Add_Website', N'P') IS NULL BEGIN
	EXEC('CREATE PROC dbo.UserData_Add_Website AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[UserData_Add_Website](
	@UserID BIGINT
	, @Website NVARCHAR(100)
)
AS



DECLARE @WebsiteID BIGINT;


INSERT INTO dbo.Websites(UserID, DateCreated, Website, Active)
VALUES(@UserID, GETDATE(), @Website, 1);


SET @WebsiteID = SCOPE_IDENTITY();

SELECT (
	SELECT CAST(@WebsiteID AS VARCHAR) AS websiteId
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
) AS jsonString;




GO
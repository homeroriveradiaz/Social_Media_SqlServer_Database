USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Profile_Remove_SimpleAsset]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID(N'dbo.UserData_Delete_Website', N'P') IS NULL BEGIN
	EXEC('CREATE PROC dbo.UserData_Delete_Website AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[UserData_Delete_Website](
	@UserID BIGINT
	, @WebsiteID BIGINT
)
AS


UPDATE dbo.Websites
SET Active = 0
WHERE UserID = @UserID
	AND WebsiteID = @WebsiteID;


GO
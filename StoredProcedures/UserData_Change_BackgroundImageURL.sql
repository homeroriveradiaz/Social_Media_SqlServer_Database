USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Profile_Remove_SimpleAsset]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.UserData_Change_BackgroundImageURL', N'P') IS NULL BEGIN
	EXEC('CREATE PROC dbo.UserData_Change_BackgroundImageURL AS SELECT 1;');
END;
GO

ALTER PROC dbo.UserData_Change_BackgroundImageURL(
	@UserID BIGINT
	, @BackgroundImageURL VARCHAR(100)
) AS 



UPDATE dbo.Users 
SET BackgroundImageURL = @BackgroundImageURL
WHERE UserID = @UserID
	AND Active = 1
	AND Censored = 0;


SELECT (
	SELECT dbo.fn_Get_Media_URL() + @BackgroundImageURL AS background
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
) AS JsonString;


GO
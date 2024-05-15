USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Posting_EditPosting]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.UserData_Change_AvatarImageURL', N'P') IS NULL BEGIN
	EXEC('CREATE PROC dbo.UserData_Change_AvatarImageURL AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[UserData_Change_AvatarImageURL](
	@UserID BIGINT
	, @AvatarImageURL VARCHAR(200)
)
AS


UPDATE dbo.Users
SET AvatarImageURL = @AvatarImageURL
WHERE UserID = @UserID
	AND Active = 1
	AND Censored = 0;


SELECT (
	SELECT dbo.fn_Get_Media_URL() + @AvatarImageURL AS avatar
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
) AS JsonString;


GO
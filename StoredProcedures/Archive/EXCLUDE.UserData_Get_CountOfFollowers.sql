USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[User_ThisUser_FollowersTotal]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.UserData_Get_CountOfFollowers', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserData_Get_CountOfFollowers AS SELECT 1;');
END;
GO

ALTER PROC [dbo].[UserData_Get_CountOfFollowers] (
	@UserID BIGINT	
) AS


SELECT (
	SELECT COUNT(*) AS countOfFollowers
	FROM dbo.User_UsersFollowed WITH(NOLOCK)
	WHERE UserIDFollowed = @UserID
	FOR JSON AUTO, WITHOUT_ARRAY_WRAPPER
) AS jsonString;



GO



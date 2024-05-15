USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Profile_Remove_SimpleAsset]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID(N'dbo.UserData_Change_Gender', N'P') IS NULL BEGIN
	EXEC('CREATE PROC dbo.UserData_Change_Gender AS SELECT 1;');
END;
GO

ALTER PROC dbo.UserData_Change_Gender(
	@UserID BIGINT
	, @GenderID TINYINT
) AS


IF EXISTS(SELECT 1 FROM dbo.Gender WITH(NOLOCK) WHERE GenderID = @GenderID) BEGIN

	UPDATE dbo.Users
	SET Gender = @GenderID
	WHERE UserID = @UserID
		AND Active = 1
		AND Censored = 0;

END;


GO
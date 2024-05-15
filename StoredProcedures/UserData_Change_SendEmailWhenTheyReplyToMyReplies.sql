USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Profile_Remove_SimpleAsset]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


IF OBJECT_ID(N'dbo.UserData_Change_SendEmailWhenTheyReplyToMyReplies', N'P') IS NULL BEGIN
	EXEC('CREATE PROC dbo.UserData_Change_SendEmailWhenTheyReplyToMyReplies AS SELECT 1;');
END;
GO


ALTER PROC dbo.UserData_Change_SendEmailWhenTheyReplyToMyReplies(
	@UserID BIGINT
	, @SendEmailWhenTheyReplyToMyReplies BIT
) AS



UPDATE dbo.Users
SET SendEmailWhenTheyReplyToMyReplies = @SendEmailWhenTheyReplyToMyReplies
WHERE UserID = @UserID
	AND Active = 1
	AND Censored = 0;


GO
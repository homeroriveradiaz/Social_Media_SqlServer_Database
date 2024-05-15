USE [ReadWrite_Prod]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_username_recovery_email_subject]    Script Date: 27/01/2018 10:23:24 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/***************************************************************************
	RETURNS THE SUBJECT TO USE IN USERNAME RECOVERY BY LANGUAGEID
***************************************************************************/
CREATE FUNCTION [dbo].[fn_get_username_recovery_email_subject](
	@LanguageID INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	

	DECLARE @Subject NVARCHAR(MAX) = 
		CASE
			WHEN @LanguageID = 1 THEN N'{0}, this is your username for ClasificAds' --English
			WHEN @LanguageID = 2 THEN N'{0}, este es tu nombre de usuario para ClasificAds' --Spanish
		END;


	RETURN @Subject;

END

GO



/****** Object:  UserDefinedFunction [dbo].[fn_get_password_recovery_email_subject]    Script Date: 11/03/2017 1:57:00 p. m. ******/
USE ReadWrite_Prod;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/***************************************************************************
	RETURNS THE SUBJECT TO USE IN PASSWORD RECOVERY BY LANGUAGEID
***************************************************************************/
CREATE FUNCTION dbo.fn_get_password_recovery_email_subject(
	@LanguageID INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	

	DECLARE @Subject NVARCHAR(MAX) = 
		CASE
			WHEN @LanguageID = 1 THEN N'{0}, reset your password for ClasificAds' --English
			WHEN @LanguageID = 2 THEN N'{0}, crea una nueva contraseña para ClasificAds' --Spanish
		END;


	RETURN @Subject;

END
GO

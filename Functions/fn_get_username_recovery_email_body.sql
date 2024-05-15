USE [ReadWrite_Prod]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_username_recovery_email_body]    Script Date: 27/01/2018 10:20:33 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*******************************************************************************
	RETURNS THE EMAIL BODY MESSAGE TO USE FOR USERNAME RECOVER BY LANGUAGEID
*******************************************************************************/
CREATE FUNCTION [dbo].[fn_get_username_recovery_email_body](
	@LanguageID INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	
	--{0} es el username
	DECLARE @Body NVARCHAR(MAX) = 
		CASE
			WHEN @LanguageID = 1 THEN N'We received a notification that you lost your username. Here it is: ''{0}''.' --English
			WHEN @LanguageID = 2 THEN N'Recibimos notificación de que perdiste tu nombre de usuario. Aquí lo tienes: ''{0}''.' --Spanish
		END;


	RETURN @Body;

END

GO



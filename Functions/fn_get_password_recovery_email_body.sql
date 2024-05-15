/****** Object:  UserDefinedFunction [dbo].[fn_fn_get_password_recovery_email_body]    Script Date: 11/03/2017 1:57:00 p. m. ******/
USE ReadWrite_Prod;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************************
	RETURNS THE EMAIL BODY MESSAGE TO USE FOR PASSWORD RECOVER BY LANGUAGEID
*******************************************************************************/
CREATE FUNCTION dbo.fn_get_password_recovery_email_body(
	@LanguageID INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	
	--{0} es el userid, {1} es el lost password token
	DECLARE @Body NVARCHAR(MAX) = 
		CASE
			WHEN @LanguageID = 1 THEN N'<div>We received a notification that you lost your password. We need you to please <a href=''https://clasificads.com/LostPasswordLink_Redirect.aspx?token1={0}&token2={1}'' target=''_blank''>click here to reset your password.</a>. This option expires in 15 minutes for security reasons. If you can''t use it within 15 minutes you can restart the process from our website again. Please do not reply to this e-mail as this is an automated message.</div>' --English
			WHEN @LanguageID = 2 THEN N'<div>Recibimos notificación de que perdiste tu contraseña. Por favor haga clic <a href=''https://clasificads.com/LostPasswordLink_Redirect.aspx?token1={0}&token2={1}'' target=''_blank''>aquí para restablecer la contraseña.</a>. Esta opción expira en 15 minutos por razones de seguridad. Si no puede utilizarla dentro de este tiempo puede volver a comenzar el proceso desde nuestro sitio web. Por favor no responda a este correo electrónico ya que se envió de forma automática.</div>' --Spanish
		END;


	RETURN @Body;

END
GO
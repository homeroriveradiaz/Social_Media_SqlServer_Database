/**********************************************************************************

ETAPA I

EL PRIMER ESCENARIO ES UN USUARIO NUEVO QUE NO SE HA INSCRITO AL SITIO
LA SUSCRIPCIÓN TIENE VARIOS PASOS POR LO QUE VARIOS ENDPOINTS SON NECESARIOS.

**********************************************************************************/





DECLARE @NewUserID BIGINT
	, @NewUserName NVARCHAR(100) = 'Chamanta'
	, @NewCAPTCHA NVARCHAR(100) = N'abc1234'
	, @CaptchaID BIGINT
	, @NewSubscriptionToken NVARCHAR(100) = N'xxxoooppppeeeeerrrrsssss'
	, @ExistsBool BIT
	, @String NVARCHAR(MAX)
	, @BackgroundImagePath VARCHAR(100) = N'BCKGRNDIMG.png' --El background img path debe ser una constante en la API
	, @FemaleAvatarImagePath VARCHAR(100) = N'FMLVTRIMG.png' --El female avatar img path debe ser una constante en la API
	, @MaleAvatarImagePath VARCHAR(100) = N'MLVTRIMG.png' --El male avatar img path debe ser una constante en la API
	, @Password NVARCHAR(100) = N'abc1234';

DECLARE @BigIntTable TABLE (Value BIGINT);
DECLARE @BoolTable TABLE (Value BIT);
DECLARE @StringTable TABLE (Value NVARCHAR(MAX));




DECLARE @PenName NVARCHAR(100) = 'Chuchita Perez'
	, @DateOfBirth SMALLDATETIME = '10/20/1988'
	, @Gender TINYINT = 2
	, @SecurityQuestion NVARCHAR(100) = 'pregunta de seguridad'
	, @SecurityAnswer NVARCHAR(100) = 'respuesta de seguridad'
	, @ContactEmail NVARCHAR(100) = 'uncorreo@correo.com.mx'
	, @SendEmailWhenTheyReplyToMyReplies BIT = 1
	, @SendEmailWhenTheyReplyToMyPostings BIT = 1
	, @SendEmailWithNewsletter BIT = 1
	, @IpAddress DECIMAL(38, 0) = 100019282828
	, @IPAddressVersion varchar(10) = 1
	, @LanguageID INT = 2;





--//// ENDPOINT 1. RESERVERVAR UN NOMBRE DE USUARIO Y UN PASSWORD:
INSERT INTO @BigIntTable(Value)
EXEC dbo.UserSubscription_ReserveUsernameAndPassword
	@Username = @NewUserName
	, @Password = @Password;


SELECT @NewUserID = MAX(Value)
FROM @BigIntTable;

DELETE @BigIntTable;

IF (@NewUserID = -9000000000000000001) BEGIN
	SELECT 'FALLAS. Creaccion de usuario, ya existe el user o se dio otro problema.';
	RETURN;
END; ELSE BEGIN
	SELECT 'Se creo el userID ' + CAST(@NewUserID AS VARCHAR);
END;


--EN ESTE MISMO ENDPOINT, MEDIANTE C# SE GENERARA UN TOKEN (100 CARACTERES ALFABETICOS RANDOM) QUE VALIDA QUE HAYA UNA SUSCRIPCION PARA ESTE USUARIO.
--ESTO AYUDA A QUE NO SE VIOLE EL DEBIDO PROCESO DE SUSCRIPCION.
EXEC dbo.UserSubscription_RegisterSubscriptionToken
	@UserID = @NewUserID,
	@Token = @NewSubscriptionToken;

SELECT 'Se ha registrado el token de suscripcion'


--ASI MISMO, SE DEBE GENERAR UNA CAPTCHA DE 6 CARACTERES Y REGISTRARSE (SIN REVELARSE AL USUARIO), LA CUAL AYUDARA AL USUARIO A CONFIRMAR QUE NO ES UN BOT O ALGO ASI:
--EL CAPTCHA SERA GENERADO SIEMPRE POR C#
--EL CAPTCHA TIENE UN ID. ESTE SI SE DEBE DEVOLVER, PARA QUE EL USUARIO INTENTE INGRESAR EL PARA ID-CAPTCHA Y LO IDENTIFIQUE LA BASE DE DATOS.

INSERT INTO @BigIntTable(Value)
EXEC [dbo].[UserSubscription_StoreNewCaptcha]
	@UserID = @NewUserID
	, @Captcha = @NewCAPTCHA;
--DEVUELVE UNA SOLA COLUMNA Y UN SOLO ROW CON EL CAMPO

SELECT @CaptchaID = MAX(Value)
FROM @BigIntTable;
DELETE @BigIntTable;

SELECT 'Se ha creado el CaptchaID ' + CAST(@CaptchaID AS VARCHAR);



--//// ENDPOINT 2. OBTENER LA IMAGEN DEL CAPTCHA DE SUSCRIPCION PARA QUE EL USUARIO PUEDA IDENTIFICARSE COMO NO-BOT
--PRECUACION: ESTE ENDPOINT SE USUARA COMO IMG SRC EN LA WEB: DEVUELVE UN JPG CON LA IMAGEN DEL CAPTCHA
--PRIMERO SE IDENTIFICA AL USUARIO POR MEDIO DE:
INSERT INTO @BoolTable(Value)
EXEC [dbo].[UserSubscription_AuthenticateCredentials]
	@UserID = @NewUserID,
	@NewUserToken = @NewSubscriptionToken;

SELECT top 1 @ExistsBool = Value
FROM @BoolTable;
DELETE @BoolTable;


IF (@ExistsBool = 1) BEGIN
	SELECT 'Se comprobo que existen el New User Token y el nuevo UserID';
END; ELSE BEGIN
	SELECT 'FALLAS. No existe el New User Token y el nuevo UserID'
	RETURN;
END;


--DESPUES SE DEBE VERIFICAR QUE EXISTE UN CAPTCHA:
INSERT INTO @BoolTable(Value)
EXEC [dbo].[UserSubscription_VerifyCaptchaIsAvailable]
	@CaptchaID = @CaptchaID,
	@UserID = @NewUserID;

SELECT top 1 @ExistsBool = Value
FROM @BoolTable;
DELETE @BoolTable;

IF (@ExistsBool = 1) BEGIN
	SELECT 'Se comprobo que existen el CaptchaID y el nuevo UserID';
END; ELSE BEGIN
	SELECT 'FALLAS. No existen el CaptchaID y el nuevo UserID'
	RETURN;
END;




--LUEGO, SE OBTIENE LA CADENA DE CARACTERES PROPIAS DEL CAPTCHA PARA PLASMARLAS EN UNA IMAGEN JPG:
INSERT INTO @StringTable(Value)
EXEC [dbo].[UserSubscription_GetCaptchaString]
	@CaptchaID = @CaptchaID,
	@UserID = @NewUserID;

SELECT @String = MAX(Value)
FROM @StringTable;

SELECT 'Se obtuvo el string de la CATPCHA y es ' + @String;


SELECT @NewCAPTCHA = N'xxyyzz';
SELECT 'Se cambiara la Captcha por el valor ' + @NewCAPTCHA

--LUEGO REGISTRAMOS LA NUEVA CAPTCHA UNA VEZ LISTA
EXEC [dbo].[UserSubscription_StoreCaptchaUpdate]
	@CaptchaID = @CaptchaID
	, @UserID = @NewUserID
	, @Captcha = @NewCAPTCHA;

SELECT 'validamos que la catpcha funciona';


INSERT INTO @BoolTable(Value)
EXEC [dbo].[UserSubscription_VerifyCaptchaIsAvailable]
	@CaptchaID = @CaptchaID,
	@UserID = @NewUserID;

SELECT top 1 @ExistsBool = Value
FROM @BoolTable;
DELETE @BoolTable;

IF (@ExistsBool = 1) BEGIN
	SELECT 'Se comprobo que existen el CaptchaID y el nuevo UserID';
END; ELSE BEGIN
	SELECT 'FALLAS. No existen el CaptchaID y el nuevo UserID'
	RETURN;
END;





INSERT INTO @BoolTable(Value)
EXEC [dbo].[UserSubscription_CheckIfEmailExistsAlready]
	@Email = @ContactEmail;

SELECT top 1 @ExistsBool = Value
FROM @BoolTable;
DELETE @BoolTable;

IF (@ExistsBool = 0) BEGIN
	SELECT 'Se comprobo que no existe el Email';
END; ELSE BEGIN
	SELECT 'FALLAS. el email ya existia.'
	RETURN;
END;





--SI TODO BIEN AL MOMENTO, SE REGISTRA LA INFO DEL USUARIO:
EXEC [dbo].[UserSubscription_SetUserData]
	@UserID = @NewUserID
	, @PenName  = @PenName
	, @DateOfBirth  = @DateOfBirth
	, @Gender = @Gender
	, @SecurityQuestion = @SecurityQuestion
	, @SecurityAnswer = @SecurityAnswer
	, @ContactEmail = @ContactEmail
	, @SendEmailWhenTheyReplyToMyReplies = @SendEmailWhenTheyReplyToMyReplies
	, @SendEmailWhenTheyReplyToMyPostings = @SendEmailWhenTheyReplyToMyPostings
	, @SendEmailWithNewsletter = @SendEmailWithNewsletter
	, @IpAddress = @IpAddress
	, @IPAddressVersion = @IPAddressVersion
	, @LanguageID = @LanguageID
	, @CaptchaID = @CaptchaID 
	, @Captcha = @NewCAPTCHA;


SELECT 'El registro de los datos de usuario fue exitoso! La captcha ya no debe funcionar';



INSERT INTO @BoolTable(Value)
EXEC [dbo].[UserSubscription_VerifyCaptchaIsAvailable]
	@CaptchaID = @CaptchaID,
	@UserID = @NewUserID;

SELECT top 1 @ExistsBool = Value
FROM @BoolTable;
DELETE @BoolTable;

IF (@ExistsBool = 1) BEGIN
	SELECT 'FALLAS! El CaptchaID esta disponible pese a que se agregaron datos de la cuenta.';
	RETURN;
END; ELSE BEGIN
	SELECT 'BIEN! No existe el CaptchaID debido a que ya se cerro la informacion de usuario.';
END;


SELECT 'Ahora a activar la cuenta';



EXEC [dbo].[UserSubscription_ActivateNewUserAccount]
	@UserID = @NewUserID
	, @NewUserToken = @NewSubscriptionToken
	, @BackgroundImagePath = @BackgroundImagePath --El background img path debe ser una constante en la API
	, @FemaleAvatarImagePath = @FemaleAvatarImagePath --El female avatar img path debe ser una constante en la API
	, @MaleAvatarImagePath = @MaleAvatarImagePath; --El male avatar img path debe ser una constante en la API


SELECT 'ACTIVADA. ahora la autenticacion de token debe fallar';


INSERT INTO @BoolTable(Value)
EXEC [dbo].[UserSubscription_AuthenticateCredentials]
	@UserID = @NewUserID,
	@NewUserToken = @NewSubscriptionToken;

SELECT top 1 @ExistsBool = Value
FROM @BoolTable;
DELETE @BoolTable;


IF (@ExistsBool = 1) BEGIN
	SELECT 'FALLAS! Ya no se deberia poder autenticar el token, sin embargo esta disponible.';
	RETURN;
END; ELSE BEGIN
	SELECT 'BIEN! el New User Token ya no existe porque ya se culmino el proceso de suscripcion';
END;


SELECT 'Listo. La cuenta debe estar ativa. Utiliza estos datos para las pruebas posteriores a este punto.' AS Result
	, @NewUserID AS NewUserID
	, @Password AS [Password]
	, @NewUserName AS NewUserName
	, @BackgroundImagePath AS BackgroundImagePath
	, @FemaleAvatarImagePath AS FemaleAvatarImagePath
	, @MaleAvatarImagePath AS MaleAvatarImagePath
	, @PenName AS PenName
	, @DateOfBirth AS DateOfBirth
	, @Gender AS Gender
	, @SecurityQuestion AS SecurityQuestion
	, @SecurityAnswer AS SecurityAnswer
	, @ContactEmail AS ContactEmail
	, @SendEmailWhenTheyReplyToMyReplies AS SendEmailWhenTheyReplyToMyReplies
	, @SendEmailWhenTheyReplyToMyPostings AS SendEmailWhenTheyReplyToMyPostings
	, @SendEmailWithNewsletter AS SendEmailWithNewsletter
	, @LanguageID AS LanguageID;








RETURN;






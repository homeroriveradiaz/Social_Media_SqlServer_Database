/***************************************************************************

ETAPA II

PROBAR LOS SPROCS DE SESION DE USUARIO

***************************************************************************/

DECLARE @UserName NVARCHAR(100) = 'Chuchita'
	, @Password NVARCHAR(100) = N'abc1234'
	, @TokenRandom NVARCHAR(100) = N'abcdefghijklmnopqrstuvwxyzzyxwutsrqponmlkjihgfedcba'
	, @IP DECIMAL(35, 0) = 1234567890
	, @IPAddressVersionID TINYINT = 1
	, @DeviceID INT = 2
	, @UserID BIGINT;


DECLARE @TablaBigint TABLE(Value BIGINT);






SELECT 'LOS SIGUIENTES SELECTS REFLEJAN EVENTOS FALLIDOS DE UserLogin_ValidateUsernameAndPassword, UserLogin_DeleteSession Y UserLogin_AuthenticateCredentials, EN ESE ORDEN';

/***** VERIFICAR SITUACIONES NO VALIDAS *******/
EXEC [dbo].[UserLogin_ValidateUsernameAndPassword]
	@Username = 'usuario no valido',
	@Password = 'mal password';


EXEC [dbo].[UserLogin_DeleteSession]
	@SessionToken = ''
	, @UserID = -9000000000000999999
	, @IPAddress = 33333333333
	, @DeviceID = 5;


EXEC [dbo].[UserLogin_AuthenticateCredentials]
	@SessionToken = 'xxxxyyyyzzzzaaaabbbcc'
	, @UserID = -9000000000000999999
	, @IPAddress = 333333333333
	, @DeviceID = 8;






SELECT 'EL SIGUIENTE ES UN EVENTO EXITOSO DE UserLogin_ValidateUsernameAndPassword';
EXEC [dbo].[UserLogin_ValidateUsernameAndPassword]
	@UserName = @UserName,
	@Password = @Password;

INSERT INTO @TablaBigint(Value)
EXEC [dbo].[UserLogin_ValidateUsernameAndPassword]
	@UserName = @UserName,
	@Password = @Password;


SELECT TOP 1 @UserID = Value
FROM @TablaBigint;

DELETE @TablaBigint;




SELECT 'TOMAMOS EL USER ID Y CREAMOS UNA SESION CON UserLogin_CreateNewSession...';
EXEC [dbo].[UserLogin_CreateNewSession]
	@UserID = @UserID,
	@Session = @TokenRandom,
	@IPAddress = @IP,
	@IPAddressVersionID = @IPAddressVersionID,
	@DeviceID = @DeviceID;



SELECT 'VAMOS A MAL-VALIDAR LA SESION CON UserLogin_AuthenticateCredentials...';
EXEC [dbo].[UserLogin_AuthenticateCredentials]
	@SessionToken = 'maltoken'
	, @UserID = @UserID
	, @IPAddress = @IP
	, @DeviceID = @DeviceID;



SELECT 'AHORA LA VAMOS A VALIDAR BIEN CON EL MISMO UserLogin_AuthenticateCredentials...';
EXEC [dbo].[UserLogin_AuthenticateCredentials]
	@SessionToken = @TokenRandom
	, @UserID = @UserID
	, @IPAddress = @IP
	, @DeviceID = @DeviceID;




SELECT 'INTENTAREMOS MAL-ELIMINAR LA SESION CON UN TOKEN NO VALIDO...';
EXEC [dbo].[UserLogin_DeleteSession]
	@SessionToken = 'maltoken'
	, @UserID = -9000000000000999999
	, @IPAddress = 33333333333
	, @DeviceID = 5;





SELECT 'AHORA LA ELIMINAMOS CORRECTAMENTE...';
EXEC [dbo].[UserLogin_DeleteSession]
	@SessionToken = @TokenRandom
	, @UserID = @UserID
	, @IPAddress = @IP
	, @DeviceID = @DeviceID;




SELECT 'POR LO QUE LA VALIDACION DE CREDENCIALES YA NO DEBE FUNCIONAR....';
EXEC [dbo].[UserLogin_AuthenticateCredentials]
	@SessionToken = @TokenRandom
	, @UserID = @UserID
	, @IPAddress = @IP
	, @DeviceID = @DeviceID;









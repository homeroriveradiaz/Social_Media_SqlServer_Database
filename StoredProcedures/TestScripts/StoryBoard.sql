/**********************************************************************************

EL PRIMER ESCENARIO ES UN USUARIO NUEVO QUE NO SE HA INSCRITO AL SITIO
LA SUSCRIPCIÓN TIENE VARIOS PASOS POR LO QUE VARIOS ENDPOINTS SON NECESARIOS.

**********************************************************************************/

--//// ENDPOINT 1. RESERVERVAR UN NOMBRE DE USUARIO Y UN PASSWORD:
EXEC dbo.UserSubscription_ReserveUsernameAndPassword
	@Username NVARCHAR(100)
	, @Password NVARCHAR(100);
-- DEVUELVE...
NewUserID --Long

--EN ESTE MISMO ENDPOINT, MEDIANTE C# SE GENERARA UN TOKEN (100 CARACTERES ALFABETICOS RANDOM) QUE VALIDA QUE HAYA UNA SUSCRIPCION PARA ESTE USUARIO.
--ESTO AYUDA A QUE NO SE VIOLE EL DEBIDO PROCESO DE SUSCRIPCION.
EXEC dbo.UserSubscription_RegisterSubscriptionToken
	@UserID BIGINT,
	@Token NVARCHAR(100);
--NO DEVUELVE NADA


--ASI MISMO, SE DEBE GENERAR UNA CAPTCHA DE 6 CARACTERES Y REGISTRARSE (SIN REVELARSE AL USUARIO), LA CUAL AYUDARA AL USUARIO A CONFIRMAR QUE NO ES UN BOT O ALGO ASI:
--EL CAPTCHA SERA GENERADO SIEMPRE POR C#
--EL CAPTCHA TIENE UN ID. ESTE SI SE DEBE DEVOLVER, PARA QUE EL USUARIO INTENTE INGRESAR EL PARA ID-CAPTCHA Y LO IDENTIFIQUE LA BASE DE DATOS.
EXEC [dbo].[UserSubscription_StoreNewCaptcha]
	@UserID BIGINT
	, @Captcha VARCHAR(50);
--DEVUELVE UNA SOLA COLUMNA Y UN SOLO ROW CON EL CAMPO
CaptchaID --long





--//// ENDPOINT 2. OBTENER LA IMAGEN DEL CAPTCHA DE SUSCRIPCION PARA QUE EL USUARIO PUEDA IDENTIFICARSE COMO NO-BOT
--PRECUACION: ESTE ENDPOINT SE USUARA COMO IMG SRC EN LA WEB: DEVUELVE UN JPG CON LA IMAGEN DEL CAPTCHA
--PRIMERO SE IDENTIFICA AL USUARIO POR MEDIO DE:
EXEC [dbo].[UserSubscription_AuthenticateCredentials]
	@UserID BIGINT,
	@NewUserToken NVARCHAR(100);
--DEVUELVE UNA SOLA COLUMNA Y UN SOLO ROW CON EL CAMPO
[Exists] --bool



--DESPUES SE DEBE VERIFICAR QUE EXISTE UN CAPTCHA:
EXEC [dbo].[UserSubscription_VerifyCaptchaIsAvailable]
	@CaptchaID BIGINT,
	@UserID BIGINT;
--DEVUELVE UNA SOLA COLUMNA Y UN SOLO ROW CON EL CAMPO
[Exists] --bool



--LUEGO, SE OBTIENE LA CADENA DE CARACTERES PROPIAS DEL CAPTCHA PARA PLASMARLAS EN UNA IMAGEN JPG:
EXEC [dbo].[UserSubscription_GetCaptchaString]
	@CaptchaID BIGINT,
	@UserID BIGINT;
--DEVUELVE UNA SOLA COLUMNA Y UN SOLO ROW CON EL CAMPO
Captcha --string



--Y YA ENTONCES SE CREARIA EL JPG A SER DEVUELTO




--//// ENDPOINT 3. RECREAR LA CAPTCHA EN CASO DE QUE EL USUARIO NO PUEDA LEERLA
--PRIMERO SE IDENTIFICA AL USUARIO POR MEDIO DE:
EXEC [dbo].[UserSubscription_AuthenticateCredentials]
	@UserID BIGINT,
	@NewUserToken NVARCHAR(100);
--DEVUELVE UNA SOLA COLUMNA Y UN SOLO ROW CON EL CAMPO
[Exists] --bool

--DESPUES SE DEBE VERIFICAR QUE EXISTE UN CAPTCHA:
EXEC [dbo].[UserSubscription_VerifyCaptchaIsAvailable]
	@CaptchaID BIGINT,
	@UserID BIGINT;
--DEVUELVE UNA SOLA COLUMNA Y UN SOLO ROW CON EL CAMPO
[Exists] --bool


--EN C# SE DEBE CREAR UNA NUEVA CAPTCHA Y VERIFICAR QUE NO SEA IGUAL A LA ANTERIOR (POR SI LAS MOSCAS)
--ENTONCES OBTENEMOS EL CAPTCHA ANTERIOR:
EXEC [dbo].[UserSubscription_GetCaptchaString]
	@CaptchaID BIGINT,
	@UserID BIGINT;
--DEVUELVE UNA SOLA COLUMNA Y UN SOLO ROW CON EL CAMPO
Captcha --string

--E ITERAMOS HASTA OBTENER UNA CAPTCHA QUE SEA DIFERENTE

--LUEGO REGISTRAMOS LA NUEVA CAPTCHA UNA VEZ LISTA
EXEC [dbo].[UserSubscription_StoreCaptchaUpdate]
	@CaptchaID BIGINT
	, @UserID BIGINT
	, @Captcha VARCHAR(50);
--NO DEVUELVE NADA






--//// ENDPOINT 4. LLENAR DATOS PARA INSCRIPCION DEL USUARIO, Y DEJARLA A PUNTO PARA CONFIRMAR.
--ESTE ENDPOINT ADEMAS DE CONFIRMAR QUE EL RESULTADO ES POSITIVO, DEBE DE ENVIAR UN CORREO CON 
--UN LINK AL USUARIO PARA QUE PUEDA CONFIRMAR SUSCRIPCION E INICIAR ACTIVIDADES

--PRIMERO SE IDENTIFICA AL USUARIO POR MEDIO DE:
EXEC [dbo].[UserSubscription_AuthenticateCredentials]
	@UserID BIGINT,
	@NewUserToken NVARCHAR(100);
--DEVUELVE UNA SOLA COLUMNA Y UN SOLO ROW CON EL CAMPO
[Exists] --bool



--LUEGO SE VERIFICA QUE LA CAPTCHA SEA VALIDA:
EXEC [dbo].[UserSubscription_VerifyCaptchaIsAccurate]
	@CaptchaID BIGINT
	, @UserID BIGINT
	, @Captcha VARCHAR(50);
--DEVUELVE UNA SOLA COLUMNA Y UN SOLO ROW CON EL CAMPO
[Valid] --bool



--EN ESTE PASO SE TIENE QUE REVISAR SI EL CORREO ELECTRONICO CON EL QUE SE VAN A REGISTRAR ES DUPLICADO ANTES DE REGISTRARLO.
EXEC [dbo].[UserSubscription_CheckIfEmailExistsAlready]
	@Email NVARCHAR(100);
--DEVUELVE UNA SOLA COLUMNA Y UN SOLO ROW CON EL CAMPO
[EmailAlreadyExists] --bool


--SI TODO BIEN AL MOMENTO, SE REGISTRA LA INFO DEL USUARIO:
EXEC [dbo].[UserSubscription_SetUserData]
	@UserID BIGINT
	, @PenName NVARCHAR(100)
	, @DateOfBirth SMALLDATETIME
	, @Gender TINYINT
	, @SecurityQuestion NVARCHAR(100)
	, @SecurityAnswer NVARCHAR(100)
	, @ContactEmail NVARCHAR(100)
	, @SendEmailWhenTheyReplyToMyReplies BIT
	, @SendEmailWhenTheyReplyToMyPostings BIT
	, @SendEmailWithNewsletter BIT
	, @IpAddress DECIMAL(38, 0)
	, @IPAddressVersion varchar(10)
	, @LanguageID INT
	, @CaptchaID BIGINT
	, @Captcha VARCHAR(50);
--NO DEVUELVE NADA





-- //// ENDPOINT 5. REENVIAR EL CORREO DE SUSCRIPCION EN CASO QUE EL USUARIO NO HAYA PODIDO RECIBIRLO
--EN ESTE CASO, TODOS LOS DATOS ESTAN DISPONIBLES EN LA PAGINA DE SUSCRIPCION, TODO LO QUE
--HAY QUE HACER ES VERIFICAR QUE LA CUENTA ESTE EN "ESTADO" DE RECIBIR UN SEGUNDO CORREO DE SUSCRIPCION
--POR EJEMPLO, QUE NO ESTE ACTIVA, QUE HAYA UN CAPTCHA CONFIRMADO, UN NEWUSERTOKEN
EXEC UserSubscription_ConfirmIfOkToResendEmail
	@UserID BIGINT
	, @Email NVARCHAR(100)
	, @NewUserToken NVARCHAR(100)

--DEVUELVE 
OkToResendSubscriptionEmail --bool
--Y LO QUE HAy Que hACER ES REENviAR EL CORREO



-- //// ENDPOINT 6. CONFIRMAR SUSCRIPCION POR CORREO ELECTRONICO.
-- HAY CONTROVERSIA RESPECTO A QUE SI DEBE SER UN ENDPOINT O DEBE SER UNA PAGINA COMPLETA DEBIDO A QUE NECESITA ESTAR LIGADO
-- A QUE SI LE DAS CLIC APAREZCA ALGO EN EL DISPOSITIVO, POR EJEMPLO LA PAGINA DE USUARIO DE INICIO.
-- HAY OTRAS CONTROVERSIAS A RESOLVER, COMO POR EJEMPLO, LA IMPLEMENTACION DE IMAGENES DE INICIO: EN QUE FOLDER VAN A IR?
-- VER ConfirmSubscription_Redirect.aspx (.cs)

--1era CONCLUSION: SI SE NECESITA ENDPOINT, AUNQUE ESTE NO VAYA A ESTAR EN EL LINK DEL CORREO.
--PRIMERO SE IDENTIFICA AL USUARIO POR MEDIO DE:
EXEC [dbo].[UserSubscription_AuthenticateCredentials]
	@UserID BIGINT,
	@NewUserToken NVARCHAR(100);
--DEVUELVE UNA SOLA COLUMNA Y UN SOLO ROW CON EL CAMPO
[Exists] --bool

--DESPUES SE EJECUTA ESTE 
EXEC [dbo].[UserSubscription_ActivateNewUserAccount]
	@UserID BIGINT
	, @NewUserToken NVARCHAR(100)
	, @BackgroundImagePath VARCHAR(100) --El background img path debe ser una constante en la API
	, @FemaleAvatarImagePath VARCHAR(100) --El female avatar img path debe ser una constante en la API
	, @MaleAvatarImagePath VARCHAR(100) --El male avatar img path debe ser una constante en la API
--NO DEVUELVE NADA


/**********************************************************************************

EN ESTE SEGUNDO ESCENARIO EL USUARIO YA ESTA INSCRITO Y SE LE DEBE DAR ACCESO 
A LA CUENTA MEDIANTE EL SISTEMA DE TOKENS

**********************************************************************************/
-- //// ENDPOINT 7. DAR DE ALTA UNA SESION DE USUARIO
--PRIMERO HAY QUE VALIDAR EL USARNAME Y EL PASSWORD
EXEC [dbo].[UserLogin_ValidateUsernameAndPassword]
	@Username NVARCHAR(100),
	@Password NVARCHAR(100);
--DEVUELVE UNA SOLA COLUMNA Y UN SOLO ROW CON EL CAMPO
--SI DEVUELVE -9000000000000000001 ENTONCES NO FUE VALIDADO PROPIAMENTE, PUESTO QUE EL PRIMER USUARIO QUE PUEDE EXISTIR ES EL -9000000000000000000
UserID --long


--CREAR SESION:
EXEC [dbo].[UserLogin_CreateNewSession]
	@UserID BIGINT,
	@Session NVARCHAR(100),
	@IPAddress DECIMAL(35, 0),
	@IPAddressVersionID TINYINT,
	@DeviceID INT;
--NO DEVUELVE NADA


--AHORA SI, YA CREADA LA SESION Y LUEGO DEVOLVER LOS TOKENS A LA APLICACION PARA IDENTIFICARSE EN TODO MOMENTO:
--token1 = string random de 30 - 100 caracteres
--token2 = id de usuario --long
--token3 = ip en decimal
--token4 = version de ip protocol, 1 para v4, 2 para v6
--PARA IDENTIFICAR AL USUARIO SOLO HAY QUE USAR:
EXEC [dbo].[UserLogin_AuthenticateCredentials]
	@SessionToken NVARCHAR(100)
	, @UserID BIGINT
	, @IPAddress DECIMAL(35, 0)
	, @DeviceID INT


--A PARTIR DE QUE EXISTE UNA SESION, TODOS LOS ENDPOINTS PARA DARLE SERVICIO DEBEN 
--SER IDENTIFICADOS POR MEDIO DEL SPROC UserLogin_AuthenticateCredentials antes de crear cualquier cosa.
--PARA HACER UN "LOG OUT" SE ELIMINA LA SESION CON ESTE SPROC...
EXEC [UserLogin_DeleteSession]
	@SessionToken NVARCHAR(100)
	, @UserID BIGINT 
	, @IPAddress BIGINT 
	, @DeviceID INT


/************************************************************************************************
LA SIGUIENTE LISTA DE ENDPOINTS TRATAN DE AGREGAR COSAS A LA CUENTA EN CATEGORIAS
-POR EJEMPLO, TELEFONOS A DESPLEGAR EN LA INFORMACION DE CONTACTO
-DIRECCIONES A MOSTRAR EN LA INFO DE CONTACTO.
-IMAGENES QUE LA CUENTA HABRA DE UTILIZAR EN SUS PUBLICACIONES O RESPUESTAS

TODOS ESTOS ELEMENTOS SE ACUMULAN: SE CREAN Y SE ACUMULAN.
Y ASI MISMO, PUEDEN SER ELIMINADOS DE LA CUENTA, UNO A UNO.

RECUERDA QUE TODO ENDPOINT AQUI DESCRITO DEBE IR PRECEDIDO DE LA IDENTIFICACION DEL USUARIO POR
MEDIO DE...

--SE IDENTIFICA LA SESION...
EXEC [dbo].[UserLogin_AuthenticateCredentials]
	@SessionToken NVARCHAR(100)
	, @UserID BIGINT
	, @IPAddress DECIMAL(35, 0)
	, @DeviceID INT;
--DEVUELVE UNA SOLA COLUMNA Y UN SOLO ROW CON EL CAMPO
Valid --bool

SE OBVIA EL USO DE DICHO SPROC PARA LOS SIGUIENTES ENDPOINTS
************************************************************************************************/


--////ENDPOINT 8
--AGREGAR UN WEBSITE A LA LISTA DE WEBSITES DEL USUARIO
--SE IDENTIFICA LA SESION...

EXEC [dbo].[UserData_Add_Website](
	@UserID BIGINT
	, @Website NVARCHAR(100)
-- DEVUELVE UNA COLUMNA CON UN VALOR LONG
WebsiteID




--////ENDPOINT 9
--AGREGAR UN TELEFONO A LA CUENTA
--SE IDENTIFICA LA SESION...

EXEC [dbo].[UserData_Add_PhoneNumber](
	@UserID BIGINT
	, @PhoneNumber NVARCHAR(20)
-- DEVUELVE UNA COLUMNA CON UN VALOR LONG
PhoneNumberID





--////ENDPOINT 10
--AGREGAR UNA DIRECCION
--SE IDENTIFICA LA SESION...

EXEC [dbo].[UserData_Add_Address] (
	@UserID BIGINT
	, @Address NVARCHAR(100)
-- DEVUELVE UNA COLUMNA CON UN VALOR LONG
AddressID






--////ENDPOINT 11
--AGREGAR UNA COBERTURA GEOGRAFICA DEL NEGOCIO DEL USUARIO
--AQUI LA EXPECTATIVA ES QUE EL USUARIO INGRESE UN STRING, Y QUE
--EL SERVIDOR HALLE EL MATCH MAS CERCANO
--SE IDENTIFICA LA SESION...

EXEC [dbo].[UserData_Add_Coverage](
	@UserID BIGINT
	, @Locationstring NVARCHAR(100)
)
-- DEVUELVE UNA COLUMNA CON UN VALOR STRING
Result --covered/overtakes/add/notfound --covered es que ya esta cubierto y no hubieron cambios 
--overtakes es que cubre geografias anteriores y estas han sido eliminadas 
--add es que se agrego sin mas 
--notfound no se ingreso
CountryID,
StateID,
CityID,
ExactLocationString;




--////ENDPOINT 12
--AGREGAR UNA IMAGEN A LA CUENTA DEL USUARIO.
--SE IDENTIFICA LA SESION...
--EN ESTE CASO, EL ENDPOINT DEBE HABER TOMADO DEL USUARIO LA IMAGEN, HABERLA CONVERTIDO EN UN 
--ARCHIVO, CON UN NUMBRE UNICO CALCULADO (UN GUID PROBABLEMENTE) Y PASAR ESE NOMBRE A 
--ESTE SPROC PARA QUE QUEDE REGISTRADA
EXEC [dbo].[UserData_Add_Image](
	@UserID BIGINT
	,@FileName VARCHAR(200)
--NO DEVUELVE NADA



--////ENDPOINT 13
--DECUELVE TODAS LAS IMAGENES DE LA CUENTA PARA QUE EL USUARIO PUEDA UTILIZARLAS EN 
--CREACION DE POSTINGS, PRODUCTOS O CONTESTACIONES
[dbo].[UserData_Get_Images](
	@UserID BIGINT
)
AS
--DEVUELVE TABLA CON DOS COLUMNAS
ImageID --LONG
, [Image] --STRING




--////ENDPOINT 14
--AGREGAR UN PRODUCTO A LA CUENTA
--SE IDENTIFICA LA SESION...

EXEC [dbo].[UserData_Add_Product](
	@UserID BIGINT
	, @ProductName NVARCHAR(50)
	, @ProductDescription NVARCHAR(500)
	, @HasPrice BIT
	, @Price MONEY = NULL
	, @PriceCurrencyId INT = NULL
	, @MainImage NVARCHAR(200)
	, @ImagesString NVARCHAR(4000) = NULL
-- DEVUELVE UNA COLUMNA CON UN VALOR LONG
ProductID





--////ENDPOINT 15
--ELIMINAR UNA DIRECCION
--SE IDENTIFICA LA SESION...

EXEC [dbo].[UserData_Delete_Address]
	@UserID BIGINT
	, @AddressID BIGINT
--NO DEVUELVE NADA


--////ENDPOINT 16
--ELIMINAR UN WEBSITE DE LA LISTA
--SE IDENTIFICA LA SESION...

EXEC [dbo].[UserData_Delete_Website]
	@UserID BIGINT
	, @WebsiteID BIGINT
--NO DEVUELVE NADA




--////ENDPOINT 17
--ELIMINAR UN NUMERO TELEFONICO
--SE IDENTIFICA LA SESION...

EXEC [dbo].[UserData_Delete_PhoneNumber]
	@UserID BIGINT
	, @PhoneNumberID BIGINT
--NO DEVUELVE NADA



--////ENDPOINT 18
--ELIMINAR UNA IMAGEN
--EN ESTE CASO LA EXPECTATIVA NO ES ELIMINAR LA IMAGEN DEL SERVIDOR,
--SINO SOLO DEJARLA INACCESIBLE PARA QUE EL USUARIO LA SIGA UTILIZANDO.
--ELIMINAR UNA IMAGEN NO IMPLICA QUE SE DEBA BORRAR DE TODOS LOS POSTINGS O RESPUESTAS QUE
--HAYA CREADO EL USUARIO
--SE IDENTIFICA LA SESION...
EXEC [dbo].[UserData_Delete_Image]
	@UserID BIGINT
	, @ImageID BIGINT
--NO DEVUELVE NADA





--////ENDPOINT 19
--ELIMINAR COBERTURA
--SE IDENTIFICA LA SESION...
EXEC [dbo].[UserData_Delete_Coverage]
	@UserID BIGINT
	, @CoverageID BIGINT
--NO DEVUELVE NADA



--////ENDPOINT 20
--ELIMINAR UN PRODUCTO, YA NO ESTARA EN LA LISTA
--SE IDENTIFICA LA SESION...
EXEC [dbo].[UserData_Delete_Product]
	@UserID BIGINT,
	@ProductID BIGINT
--NO DEVUELVE NADA









--////ENDPOINT 21
--Cambiar la imagen de Avatar del usuario
--SE IDENTIFICA LA SESION...
EXEC [dbo].[UserData_Change_AvatarImageURL]
	@UserID BIGINT
	, @AvatarImageURL VARCHAR(200)




--////ENDPOINT 22
--cambiar la imagen de fondo del perfil de usuario
--SE IDENTIFICA LA SESION...
EXEC dbo.UserData_Change_BackgroundImageURL
	@UserID BIGINT
	, @BackgroundImageURL VARCHAR(100)



--////ENDPOINT 23
--cambiar el nombre del negocio, o bien, nombre publico del usuario
--SE IDENTIFICA LA SESION...
EXEC dbo.UserData_Change_Name
	@UserID BIGINT
	, @Name NVARCHAR(100)


--////ENDPOINT 24
--cambiar el slogan del negocio
--SE IDENTIFICA LA SESION...
EXEC dbo.UserData_Change_Slogan
	@UserID BIGINT
	, @Slogan NVARCHAR(100)


--////ENDPOINT 25
--cambiar preferencia de usuario sobre si recibir notificaciones por correo cuando le dan reply a sus propios postings
--SE IDENTIFICA LA SESION...
EXEC dbo.UserData_Change_SendEmailWhenTheyReplyToMyPostings
	@UserID BIGINT
	, @SendEmailWhenTheyReplyToMyPostings BIT


--////ENDPOINT 26
--cambiar la descripcion general del negocio o usuario
--SE IDENTIFICA LA SESION...
EXEC dbo.UserData_Change_BusinessDescription
	@UserID BIGINT
	, @BusinessDescription NVARCHAR(500)


--//ENDPOINT 27
--cambiar sexo (anyone can misclick right?)
--SE IDENTIFICA LA SESION...
EXEC dbo.UserData_Change_Gender
	@UserID BIGINT
	, @GenderID TINYINT



--////ENDPOINT 28
--cambiar el lenguage principal del usuario.
--SE IDENTIFICA LA SESION...
EXEC dbo.UserData_Change_Language
	@UserID BIGINT
	, @LanguageID INT



--////ENDPOINT 29
--cambiar la ubicacion principal del usuario
--SE IDENTIFICA LA SESION...
EXEC dbo.UserData_Change_MainLocation
	@UserID BIGINT
	, @CityID INT
	, @StateID INT
	, @CountryID INT
--DEVUELVE UN SOLO ROW
Found --bool
Location --string



--////ENDPOINT 30
--cambiar preferencia de usuario sobre si recibir notificaciones cuando contestan a sus contestaciones sobre otros postings
--SE IDENTIFICA LA SESION...
EXEC dbo.UserData_Change_SendEmailWhenTheyReplyToMyReplies
	@UserID BIGINT
	, @SendEmailWhenTheyReplyToMyReplies BIT


--////ENDPOINT 31
--cambiar preferencia de usuario sobre si recibir newsletter
--SE IDENTIFICA LA SESION...
EXEC dbo.UserData_Change_SendEmailWithNewsletter
	@UserID BIGINT
	, @SendEmailWithNewsletter BIT










-- //// ENDPOINT 32. OBTENER INFORMACION GENERAL DE LA CUENTA DEL USUARIO:
--SE IDENTIFICA LA SESION...
EXEC [dbo].[UserLogin_AuthenticateCredentials]
	@SessionToken NVARCHAR(100)
	, @UserID BIGINT
	, @IPAddress DECIMAL(35, 0)
	, @DeviceID INT;
--DEVUELVE UNA SOLA COLUMNA Y UN SOLO ROW CON EL CAMPO
Valid --bool

--Y AHORA SE OBTIENEN LOS DATOS PRINCIPALES DEL USUARIO PARA GENERAR UN JSON CON LA INFO DEL USUARIO A DEVOLVER AL CLIENTE
--Ver GET_ProfileInformation.ashx
EXEC dbo.UserData_Get_MainInfo
	@UserID BIGINT
--DEVUELVE UN ROW CON VARIAS COLUMNAS:
Name  --string
Slogan  --string
BusinessDescription  --string
MainLocation  --string
AvatarImageURL  --string SIN DOMINIO
BackgroundImageURL  --string SIN DOMINIO
SendEmailWhenTheyReplyToMyReplies  --string
SendEmailWhenTheyReplyToMyPostings  --string
SendEmailWithNewsletter  --string
PublicUserKey  --string


--OBTENER CANTIDAD DE SEGUIDORES
EXEC [dbo].[UserData_Get_CountOfFollowers]
	@UserID BIGINT
--DEVUELVE UNA SOLA COLUMNA Y UN SOLO ROW CON EL CAMPO
CountOfFollowers --int


--OBTENER DIRECCIONES:
EXEC [dbo].[UserData_Get_Addresses]
	@UserID BIGINT
--DEVUELVE MAS DE UN ROW CON VARIAS COLUMNAS:
AddressID --long
[Address] --string


--OBTENER WEBSITES:
[dbo].[UserData_Get_WebSites]
	@UserID BIGINT
--DEVUELVE MAS DE UN ROW CON VARIAS COLUMNAS:
WebsiteID --long
Website --string


--OBTENER TELEFONOS
EXEC [dbo].[UserData_Get_PhoneNumbers]
	@UserID BIGINT
--DEVUELVE MAS DE UN ROW CON VARIAS COLUMNAS:
PhoneNumberID --long
PhoneNumber --string


--OBTENER COBERTURA
EXEC [dbo].[UserData_Get_Coverage]
	@UserID BIGINT
--DEVUELVE MAS DE UN ROW CON VARIAS COLUMNAS:
CoverageID --long
Coverage --string



EXEC dbo.UserData_Get_Products
	@UserID BIGINT
--DEVUELVE MAS DE UN ROW CON VARIAS COLUMNAS:
ProductID --long
ProductName --string
ProductDescription --string
MainImage --string
HasPrice --bool
Price --decimal
CurrencySymbol --string
CurrencyAbbreviation --string
AttachedImagesCount --int



EXEC UserData_Get_ProductsImages
	@ProductID BIGINT
--DEVUELVE UNA TABLE CON UNA SOLA COLUMNA:
[Image]

/*
{
	name:string
	,slogan:string
	,description:string
	,mainLocation:string
	,avatarImg:string      (HAY QUE INYECTAR EL DOMINIO. NO LO LLEVA)
	,backgroundImg:string  (HAY QUE INYECTAR EL DOMINIO. NO LO LLEVA)
	,sendEmailWhenTheyReplyToMyReplies:bool
	,sendEmailWhenTheyReplyToMyPostings:bool
	,sendEmailWithNewsletter:bool
	,publicUserKey:string
	,followers:int
	,addresses:[
		{ addressId:string , address:string },
		{ addressId:string , address:string },
		{ addressId:string , address:string },
		{ addressId:string , address:string },
		{ addressId:string , address:string }
	]
	,websites:[
		{ websiteId:string , website:string },
		{ websiteId:string , website:string },
		{ websiteId:string , website:string },
		{ websiteId:string , website:string }
	]
	,phoneNumbers:[
		{ phoneNumberId:string , phoneNumber:string },
		{ phoneNumberId:string , phoneNumber:string },
		{ phoneNumberId:string , phoneNumber:string },
		{ phoneNumberId:string , phoneNumber:string }
	]
	,coverage:[
		{ coverageId:string , coverage:string },
		{ coverageId:string , coverage:string },
		{ coverageId:string , coverage:string },
		{ coverageId:string , coverage:string }
	]
	,products:[
		{ 
			productId:string 
			, productName:string 
			, productDescription:string 
			, productHasPrice:bool 
			, productPrice:decimal 
			, productCurrencySymbol:string 
			, productCurrencyAbbreviation:string 
			, productMainImage:string 
			, productImages:[
				{ productImage:string },
				{ productImage:string },
				{ productImage:string }
			] 
		},
		{ 
			productId:string 
			, productName:string 
			, productDescription:string 
			, productHasPrice:bool 
			, productPrice:decimal 
			, productCurrencySymbol:string 
			, productCurrencyAbbreviation:string 
			, productMainImage:string 
			, productImages:[
				{ productImage:string },
				{ productImage:string },
				{ productImage:string }
			] 
		},
		{ 
			productId:string 
			, productName:string 
			, productDescription:string 
			, productHasPrice:bool 
			, productPrice:decimal 
			, productCurrencySymbol:string 
			, productCurrencyAbbreviation:string 
			, productMainImage:string 
			, productImages:[
				{ productImage:string },
				{ productImage:string },
				{ productImage:string }
			] 
		}
	]
}

*/








/************************************************************************************************
LA SIGUIENTE LISTA DE ENDPOINTS TRATAN SOBRE TODO LO QUE INMISCUYE VER/HACER/EDITAR POSTINGS:

RECUERDA QUE CASI TODO ENDPOINT AQUI DESCRITO DEBE IR PRECEDIDO DE 
LA IDENTIFICACION DEL USUARIO POR MEDIO DE...

EXEC [dbo].[UserLogin_AuthenticateCredentials]
	@SessionToken NVARCHAR(100)
	, @UserID BIGINT
	, @IPAddress DECIMAL(35, 0)
	, @DeviceID INT;
--DEVUELVE UNA SOLA COLUMNA Y UN SOLO ROW CON EL CAMPO
Valid --bool

SE OBVIA EL USO DE DICHO SPROC PARA CASI TODOS LOS SIGUIENTES ENDPOINTS
************************************************************************************************/

-- //// ENDPOINT 33. PUBLICAR QUE VENDES O COMPRAS ALGO
--SE DEBE IDENTIFICAR LA SESION PUESTO QUE ESTO SOLO SE PUEDE REALIZAR EN SESION DE USUARIO
EXEC [dbo].[Postings_Add_Posting](
	@UserID BIGINT
	, @MessageTitle NVARCHAR(100)
	, @MessageBody NVARCHAR(4000)
	, @IPAddress BIGINT
	, @HasQuote BIT --SI TIENE PRECIO HAY QUE PONERLE UN TRUE
	, @Price MONEY = NULL --EL PRECIO
	, @PriceCurrencyID INT = NULL --EL ID DE LA MONEDA DEL PRECIO
	, @ImagesString NVARCHAR(4000) = NULL --LAS IMAGENES SIN DOMINIO Y ENCERRADAS ENTRE CORCHETES PEGADOS: [IMG001.JPG][IMG002.GIF][IMG003.JPG][IMG004.GIF]
	, @LocationsString NVARCHAR(4000) = NULL --LOS LOCATIONS CON ID UNIDOS POR UNDERSCORES (pais_estado_ciudad) Y ENTRE CORCHETES: [134_34_651][1_2_3][45_67_89]
--DEVUELVE UN ROW CON UNA COLUMNA, EL POSTINGID
PostingID


-- //// ENDPOINT 34. EDITAR UN POSTING TUYO
--SOLO SE PUEDEN EDITAR EL HEADER Y EL CUERPO DEL POSTING, NO LAS IMAGENES, NO LAS UBICACIONES, ETC...
--SI EL USUARIO DE PLANO NO LE GUSTO SU POSTING, ENTONCES DEBE DARLE DELETE.
--SE IDENTIFICA LA SESION...
EXEC [dbo].[Postings_Edit_Posting]
	@PostingID BIGINT
	, @MessageTitle NVARCHAR(100)
	, @MessageBody NVARCHAR(4000)
--NO DEVUELVE NADA


-- //// ENDPOINT 35. ES ELIMINAR UN POSTING QUE TU MISMO HAYAS HECHO.
--SE IDENTIFICA LA SESION...
EXEC [dbo].[Postings_Delete_Posting]
	@UserID BIGINT
	, @PostingID BIGINT
--NO DEVUELVE NADA




/***********************************************************
CUANDO VES LISTAS DE POSTINGS QUE NO SON TUYOS, PUEDES 
"GUARDARLOS A UN CAJON" (CLIP).
LOS SIGUIENTES 3 ENDPOINTS TIENEN ESE PROPOSITO.
***********************************************************/
-- //// ENDPOINT 36. GUARDA UN POSTING QUE DESEES RESERVAR EN TU 'CAJON'
--SE IDENTIFICA LA SESION...
EXEC [dbo].[Postings_Clip_Posting]
	@UserID BIGINT
	, @PostingID BIGINT;
--NO DEVUELVE NADA

-- //// ENDPOINT 37. 'DESGUARDA' UN POSTING QUE TENIAS RESERVADO EN TU 'CAJON'
EXEC [dbo].[Postings_Unclip_Posting]
	@UserID BIGINT
	, @PostingID BIGINT
--SE IDENTIFICA LA SESION...


-- //// ENDPOINT 38. TE DEVUELVE LA INFORMACION DE UN POSTING QUE HAYAS GUARDADO.
--ES SOLO UN FACILITADOR PARA AGREGAR UN POSTING AL CAJON LUEGO DE GUARDARLO
--UTILIZA 2 SPROCS, UNO PARA OBTENER LA INFO DEL POSTING Y OTRO PARA USAR SUS IMAGENES:
--SE IDENTIFICA LA SESION...
--SE OBTIENEN LOS DATOS DEL POSTING EN CUESTION:
EXEC [dbo].[Postings_Get_SingleSavedPosting]
	@UserID BIGINT
	, @PostingID BIGINT
	, @LanguageID INT
--DEVUELVE
PostingID, PostingTitle, PostingMessage, PostedOn
, ShowPriceQuote, Price, CurrencySymbol, CurrencyAbbreviation
, Avatar, PostedByUserID, [Name]
, AttachedImagesCount
--Y LAS IMAGENES UN ARRAY TAMBIEN:



/******************************************************************************
CUANDO VES LISTAS DE POSTINGS QUE NO SON TUYOS, PUEDES tAMBIEN RESPONDERLOS 
PARA CONVERSAR CON QUIEN PUBLICA.
DE LA MISMA MANERA, PUEDEN SIEMPRE RESPONDER A LOS POSTINGS QUE TU PUBLIQUES.
******************************************************************************/
-- //// ENDPOINT 39. TE PERMITE CONTESTAR AL POSTING DE ALGUIEN MAS.
--UNA VEZ HECHA LA RESPUESTA, EL POSTING DEBE SER GUARDADO EN EL CAJON.
--EL USUARIO QUE RESPONDE A UN POSTING SOLO PUEDE USAR ESTE SPROC PARA RESPONDER
--1 SE IDENTIFICA LA SESION...
--2 SE CONTESTA AL POSTING CON...
EXEC dbo.Postings_Add_ResponseToPosting
	@UserID BIGINT
	, @MessageBody NVARCHAR(4000)
	, @IPAddress BIGINT
	, @PostedInResponseToPostingID BIGINT --EL POSTINGID QUE ESTAMOS CONTESTANDO
	, @ImagesString NVARCHAR(4000) --LAS IMAGENES QUE ANEXAMOS, SIN DOMINIO Y EN UNA CADENA DE BRACKETS ASI: [IMG0001.JPG][IMG0002.PNG][IMG0003.GIF][IMG0004.JPEG]
				--DE NO HABER IMAGENES EN LA RESPUESTA, SOLO MANDA UNA CADENA VACIA ASI "".


-- //// ENDPOINT 40. CUANDO RESPONDEN A NUESTROS POSTINGS, LAS CONVERSACIONES PERMANECEN PRIVADAS
--ENTRE YO Y EL QUE CONTESTA.
--DEBIDO A QUE PUEDO TENER CONVERSACIONES CON MUCHAS PERONAS DISTINTAS, POR CADA CONVERSACION SE CREA UN THREAD.
--CUANDO QUIERO CONTESTAR A ALGUIEN QUE HA CONTESTADO MI POSTING, DEBO CONTESTAR POR MEDIO
--DEL THREAD-ID.
--SE IDENTIFICA LA SESION...
EXEC dbo.Postings_Add_ResponseToThread
	@UserID BIGINT				--The user issuing the response. THIS IS EXPECTED TO BE THE USER THAT ORGINALLY POSTED THIS
	, @RespondingUserID BIGINT  --the user that originated the thread
	, @MessageBody NVARCHAR(4000)
	, @IPAddress BIGINT
	, @PostingThreadID BIGINT	--The thread
	, @ImagesString NVARCHAR(4000) --si no hay imagenes, manda una cadena vacia ""






/********************************************************
LOS SIGUIENTES ENDPOINTS SON LOS QUE LANZAN LISTAS DE POSTINGS BASADAS EN DISTINTOS CASOS DE BUSQUEDA.
TODAS LAS RESPUESTAS DE LOS SPROCS TIENEN UNA ESTRUCTURA DE COLUMNAS BASE. 
ALGUNOS SPROCS LANZAN UNA O DOS COLUMNAS MAS A DIFERENCIAS DE SUS CONGENERES.
LA BASE ES:

PostingID				long		el numero de identificacion del posting (ej. -8970000000000000000)
PostingTitle			string		el encabezado del posting (ej. Prueba nuestros especiales de temporada)
PostingMessage			string		el cuerpo del posting (ej Starbucks trae para ti su #cafe de temporada con muchos sabores como almendra, macadamia, dark chocolate. Ven a tu Starbucks mas cercano)
PostedOn				string		hace cuanto fue publicado el posting (ej. Hace 2 semanas)
ShowPriceQuote			bool		si el producto o servicio del posting tiene un precio citado (ej. true/false)
Price					decimal		el precio del producto o servicio (ej. 10.50)
CurrencySymbol			string		el simbolo de la moneda en que se halla el precio (ej. $)
CurrencyAbbreviation	string		la abreviacion de la moneda (ej. MXN)
Avatar					string		la URL de la imagen de avatar de quien publica, que se guarda sin url en la base de datos (ej. avatars/img001.jpg)
PostedByUserID			long		el ID de usuario de quien publica (ej. -8986410000000000000)
Name					string		el nombre de quien publica (ej Starbucks)
AttachedImagesCount		int			la cantidad de imagenes que lleva el posting (ej. 7)


AQUI UNOS EJEMPLOS DE CASOS DE BUSQUEDA:
-CASO 1: POR EJEMPLO, PUEDE QUE YO ESTE CONSULTANDO/VISITANDO EL PERFIL DE UN NEGOCIO, POR EJEMPLO "Helados La Michoacana"
POR LO TANTO ME DEBEN APARECER LOS POSTINGS DE "Helados La Michoacana" Y NADA MAS.
EN ESTE CASO NO HAY PALABRAS CLAVE DE BUSQUEDA, NI UBICACIONES DE BUSQUEDA EN PARTICULAR.
-CASO 2: QUE YO UTILICE EL BUSCADOR PUBLICO PARA BUSCAR "refacciones" SIN ESTAR LOGUEADO NI NADA. 
EN ESE CASO SE TOMARA EN CUENTA MI UBICACION (DEFINIDA POR MEDIO DE MI IP), Y LA PALABRA "refacciones" DE BUSQUEDA PARA DEFINIR QUE POSTINGS DEBO VER.
-CASO 3: QUE YO ESTE EN LOGUEADO EN MI CUENTA CON 100 TERMINOS DE BUSQUEDA DISTINTOS (EJ. "SUSHI", "MASCOTAS", "TACOS", ETC ETC) 
Y CON 100 UBICACIONES ("ROMA", "PARIS", "LONDRES", "TAMPICO"). ENTONCES ME DEBEN APARECER POSTINGS RELEVANTES A TODOS ESOS CASOS.
-Y HAY MAS CASOS, QUE SE VERAN EN CADA ENDPOINT EN PARTICULAR.


TODAS LAS LISTAS VIENEN CON LOS POSTINGS DEL MAS RECIENTE AL MAS ANTIGUO
TAMBIEN TODAS LAS LISTAS DE POSTINGS VIENEN CON UNA CANTIDAD DE 20 POSTINGS A LO MUCHO (PAGINACION).
TODOS LOS SPROCS TIENEN EL PARAMETRO DE PAGINACION, "@BelowPostingID", EL CUAL ES OPCIONAL.
POR LO TANTO, SI NO SE ENVIA "@BelowPostingID", ENTONCES DICHA LISTA CORRESPONDORIA A LOS 20 POSTINGS MAS RECIENTES. 
DE DICHA LISTA, SE DEBE IDENTIFICAR EL ULTIMO POSTINGID, Y EN LA PROXIMA LLAMADA ENVIAR ESE "@BelowPostingID" CON 
DICHO POSTINGID; DE ESA FORMA, LA SIGUIENTE PORCION DE LA LISTA CORRESPONDERA A LOS SIGUIENTES 20 QUE CORRESPONDEN. 
Y ASI SUCESIVAMENTE, SE DEBE IR RESERVANDO EL ULTIMO POSTINGID PARA PASARLO COMO ARGUMENTO SI SE REQUIEREN MAS Y MAS
POSTINGS.


OTRO PUNTO A DESTACAR ES QUE LAS LISTAS DE POSTINGS PUEDEN TENER 1 O MAS HILOS DE CONVERSACION CON DISTINTOS USUARIOS.
LAS CONVERSACIONES ENTRE INTERESADOS SON PRIVADAS.
LOS POSTINGS QUE YO PUBLICO TENDRAN TANTOS HILOS COMO PERSONAS ME RESPONDAN. Y CADA UNA DE MIS RESPUESTAS A ESTOS HILOS 
SERAN VISIBLES SOLO POR LA PERSONA CON LA QUE ESTOY CONVERSANDO.
CUANDO YO CONTESTO A LA PUBLICACION DE UN TERCERO, SOLO VEO LA CONVERSACION ENTRE YO Y EL PUBLICADOR.
********************************************************/


-- //// ENDPOINT 41.
--SE IDENTIFICA LA SESION... (si se utiliza como usuario logueado)
EXEC [dbo].[Postings_Get_PostingsThatBelongToAUser]
	@UserID BIGINT
	, @UserIDThatSearches BIGINT
	, @BelowPostingID BIGINT
	, @LanguageID INT
--devuelve
PostingID, PostingTitle, PostingMessage, PostedOn
, ShowPriceQuote, Price, CurrencySymbol, CurrencyAbbreviation
, Avatar, PostedByUserID, [Name]
, AttachedImagesCount  /*PENDIENTE VER SI INCLUIMOS EL XML DE LAS IMAGENES CORRESPONDIENTES COMO UN CAMPO MAS*/
/*
Este sproc devuelve los postings de un usuario en particular que estemos visitando ya 
sea como usuario en sesion o publico en general:

@UserID (no opcional) es el usuario que esta siendo visitado, de quien queremos ver sus publicaciones.

@UserIDThatSearches (opcional) se utiliza solo en caso de que estemos logueados en sesion. Este parametro evita que se nos muestre cualquier 
posting que ya tengamos guardado (clipped).

@BelowPostingID (opcional) se utiliza para paginado. Si se omite, se nos envian los ultimos 20 postings que haya publicado este usuario.
De usarse, se nos envian los siguientes 20 postings anteriores al posting ID que enviemos.

@LanguageID (no opcional) es el idioma en que se esta consultando la pagina o aplicacion. Se utiliza para indicaciones como de "hace cuanto esta este posting"
para que sean devueltos en el idioma que corresponde.


SE ESPERA UNA RESPUESTA EN JSON COMO LA SIGUIENTE:
{
	postings:[
		{ postingId:string , postingTitle:string , postingMessage:string , postedOn:string , showPriceQuote:bool , price:decimal , currencySymbol:string , currencyAbbreviation:string
			, avatar:string , postedByUserId:string , name:string , attachedImagesCount:int , images:[ { image:string } , { image:string } , { image:string } ]
		}
		, { postingId:string , postingTitle:string , postingMessage:string , postedOn:string , showPriceQuote:bool , price:decimal , currencySymbol:string , currencyAbbreviation:string
			, avatar:string , postedByUserId:string , name:string , attachedImagesCount:int , images:[ { image:string } , { image:string } , { image:string } ]
		}
		, { postingId:string , postingTitle:string , postingMessage:string , postedOn:string , showPriceQuote:bool , price:decimal , currencySymbol:string , currencyAbbreviation:string
			, avatar:string , postedByUserId:string , name:string , attachedImagesCount:int , images:[ { image:string } , { image:string } , { image:string } ]
		}
	]
}

*/







-- //// ENDPOINT 42.
--SE IDENTIFICA LA SESION... (si se utiliza como usuario logueado)
EXEC [dbo].[Postings_Get_BasedOnSearchWords]
	@IPAddress DECIMAL(38, 0),
	@IpAddressProtocol TINYINT,
	@NewWord NVARCHAR(100),
	@LanguageID INT,
	@BelowPostingID BIGINT = NULL,
	@NotFromUserID BIGINT = NULL --THE USERID YOU DONT WANT POSTS FROM CUZ HE'S THE ONE ASKING
--devuelve
PostingID, PostingTitle, PostingMessage, PostedOn
, ShowPriceQuote, Price, CurrencySymbol, CurrencyAbbreviation
, Avatar, PostedByUserID, [Name]
, AttachedImagesCount
, VisitorSearchListPosting
, SearchWordRank
, ShortenedNameFull /*PENDIENTE VER SI INCLUIMOS EL XML DE LAS IMAGENES CORRESPONDIENTES COMO UN CAMPO MAS*/
/*
Este sproc devuelve los postings correspondientes a una busqueda simple en la que se ingresa un término de busqueda, por ejemplo "camionetas"
y en que se utiliza una IP de busqueda.

@IPAddress (no opcional) es la dirección IP convertida a decimal.

@IpAddressProtocol (no opcional) es el protocolo de la dirección IP. 1 para v4 (la de toda la vida) o 2 para v6 (el nuevo estándar que se está empezando a implementar)

@NewWord (no opcional) es lo que el usuario desea buscar.

@LanguageID (no opcional) es el idioma en que se esta consultando la pagina o aplicacion. Se utiliza para indicaciones como de "hace cuanto esta este posting"
para que sean devueltos en el idioma que corresponde.

@BelowPostingID (opcional) se utiliza para paginado. Si se omite, se nos envian los 20 postings mas recientes que encajen con esta busqueda.
De usarse, se nos envian los siguientes 20 postings anteriores al posting ID que enviemos.

@NotFromUserID (opcional) en caso de que se este en sesion de usuario, se utiliza para enviar el propio UserID y evitar que aparezcan nuestros propios
postings.


SE ESPERA UNA RESPUESTA EN JSON COMO LA SIGUIENTE:
{
	postings:[
		{ postingId:string , postingTitle:string , postingMessage:string , postedOn:string , showPriceQuote:bool , price:decimal , currencySymbol:string , currencyAbbreviation:string
			, avatar:string , postedByUserId:string , name:string , attachedImagesCount:int , images:[ { image:string } , { image:string } , { image:string } ] , locations:[ { location:string } , { location:string } , { location:string } ]
		}
		, { postingId:string , postingTitle:string , postingMessage:string , postedOn:string , showPriceQuote:bool , price:decimal , currencySymbol:string , currencyAbbreviation:string
			, avatar:string , postedByUserId:string , name:string , attachedImagesCount:int , images:[ { image:string } , { image:string } , { image:string } ] , locations:[ { location:string } , { location:string } , { location:string } ]
		}
		, { postingId:string , postingTitle:string , postingMessage:string , postedOn:string , showPriceQuote:bool , price:decimal , currencySymbol:string , currencyAbbreviation:string
			, avatar:string , postedByUserId:string , name:string , attachedImagesCount:int , images:[ { image:string } , { image:string } , { image:string } ] , locations:[ { location:string } , { location:string } , { location:string } ]
		}
	]
}

*/



-- //// ENDPOINT 43.
--SE IDENTIFICA LA SESION...
EXEC dbo.Postings_Get_PostingsThatMatchPreferences
	@UserID BIGINT
	, @LanguageID INT
	, @BelowPostingID BIGINT = NULL
--devuelve
PostingID, PostingTitle,PostingMessage, PostedOn
, ShowPriceQuote, Price, CurrencySymbol, CurrencyAbbreviation
, Avatar, PostedByUserID, [Name]
, AttachedImagesCount /*PENDIENTE VER SI INCLUIMOS EL XML DE LAS IMAGENES CORRESPONDIENTES COMO UN CAMPO MAS*/
/*
Devuelve los postings de acuerdo a las preferencias del usuario en conciliacion con:
1. sus N terminos de busqueda y 
2. sus N ubicaciones de interes 
3. asi como sus N usuarios a los que sigue
4. quitando los postings que pudiera ya tener guardados (clipped)
5. omitiendo los postings de los usuarios que sigue pero que tiene en "mute"

@UserID (no opcional) es el Id del usuario que nos pide ver sus postings de interes
@LanguageID (no opcional) es el idioma en que deberan aparecer las indicaciones
@BelowPostingID (opcional) se utiliza para paginado. Si se omite, se nos envian los 20 postings mas recientes que encajen con estos criterios.
De utilizarse, se nos envian los siguientes 20 postings anteriores al posting ID que enviemos.

*/


-- //// ENDPOINT 44.
--SE IDENTIFICA LA SESION...
EXEC [dbo].[Postings_Get_ClippedPostings]
	@UserID BIGINT
	, @LanguageID INT
--devuelve
PostingID, PostingTitle, PostingMessage, PostedOn
, ShowPriceQuote, Price, CurrencySymbol, CurrencyAbbreviation
, Avatar, PostedByUserID, [Name]
, AttachedImagesCount /*PENDIENTE VER SI INCLUIMOS EL XML DE LAS IMAGENES CORRESPONDIENTES COMO UN CAMPO MAS*/
/*LAS RESPUESTAS Y LOS HILOS DE CONVERSACION PODRIAN DEVOLVERSE COMO XML TAMBIEN. POR LO PRONTO CONTAMOS CON EL SPROC Postings_Get_PostingThreadForResponder QUE
DE MOMENTO ES EL QUE TRAE LOS HILOS DE CONVERSACION */
, [HasNotification], NotificationID 
/*
Te devuelve todos los postings a que has reservado al hacer "clip" para guardarlos.
Es decir, son todos los postings de otras personas que decidiste guardar, y que podrian tener un hilo de conversacion activo.

A diferencia de todas las demas listas esta no tiene paginado: se te devuelven TODOS los postings que cumplan con las condiciones.

@UserID (no opcional) es el usuario que quiere ver los postings que el mismo ha guardado

@LanguageID (no opcional) es el numero de identificacion del idioma en que se esta consultando la aplicacion. Esto controla el idioma de ciertas indicaciones que 
son mostradas como datos en el JSON de respuesta.
*/
--ESTE ENDPOINT DEBE LLEVAR POR RESPUESTA TAMBIEN CUALQUIER HILO DE CONVERSACION QUE PUDIERA EXISTIR PARA CADA POSTING EN LA LISTAS ANTERIOR.
EXEC dbo.Postings_Get_PostingThreadForResponder
	@UserID BIGINT
	, @LanguageID INT
	, @PostingID BIGINT
--devuelve
PostingInThreadID --irrelevante para este endpoint, no se incluir en la respuesta
PostedByUserID, PostingMessage, PostedOn, Name, Avatar, SumOfAttachments, PostDateTime
/*PENDIENTE VER SI INCLUIMOS EL XML DE LAS IMAGENES CORRESPONDIENTES COMO UN CAMPO MAS*/



-- //// ENDPOINT 45.
--SE IDENTIFICA LA SESION...
EXEC dbo.Postings_Get_PostingsThatBelongToThisUser
	@UserID BIGINT
	, @LanguageID INT
	, @BelowPostingID BIGINT = NULL
--devuelve
PostingID, PostingTitle, PostingMessage, PostedOn
, ShowPriceQuote, Price, CurrencySymbol, CurrencyAbbreviation
, Avatar, PostedByUserID, [Name]
, AttachedImagesCount  /*PENDIENTE VER SI INCLUIMOS EL XML DE LAS IMAGENES CORRESPONDIENTES COMO UN CAMPO MAS*/
, HasNotifications
/*
Devuelve todos los postings que has publicado. Igual que en los casos anteriores salvo por Postings_Get_ClippedPostings, lo hace de
forma paginada.
*/
--Este endpoint debe llevar para todo posting una lista de threads y sus notificaciones
EXEC dbo.Postings_Get_ThreadsInPosting
	@UserID BIGINT
	, @PostingID BIGINT
	, @LanguageID INT
--devuelve
PostingThreadID, RespondingUserID, PostedOn, Name
, Avatar, HasNotification, NotificationId, ThreadActive



-- //// ENDPOINT 46.
--SIRVE PARA VER EL CONTENIDO DE LOS THREADS. A DIFERENCIA DE CUANDO ESTOY SIGUIENDO UN POSTING, CUANDO YO LO PUBLICO PUEDE HABER MUCHISIMOS THREADS, 
--ASI QUE PARA MEJOR CONTROL SIMPLEMENTE SE CARGAN HASTA ENTRAR A ALGUN THREAD
--SE IDENTIFICA LA SESION Y SE PROCEDE...
EXEC [dbo].[Postings_Get_PostingsInPostingsThreadID]
	@PostingThreadID BIGINT
	, @LanguageID INT
--devuelve...
PostingInThreadID, PostedByUserID, PostingMessage
, PostedOn, Name, Avatar, SumOfAttachments, PostDateTime
 /*PENDIENTE VER SI INCLUIMOS EL XML DE LAS IMAGENES CORRESPONDIENTES COMO UN CAMPO MAS*/






/********************************************************************************************************************************
FAMILIA: SuiGenerisSearchCriteria_

EN LA FAMILIA "Postings_" HABIA UNA LISTA MUY ESPECIAL QUE ERA LA DEL SPROC Postings_Get_PostingsThatMatchPreferences
DICHO SPROC TENIA LAS SIGUIENTES CAPACIDADES DE BUSQUEDA SUPERIORES ENTRE LAS QUE SE CUENTAN...
-NUMERO ILIMITADO DE TERMINOS DE BUSQUEDA SIMULTANEOS
-NUMERO ILIMITADO DE UBICACIONES DE BUSQUEDA SIMULTANEAS
-SEGUIR USUARIOS PARA SIEMPRE SEGUIR SUS PUBLICACIONES
-PONER EN MUTE DICHOS USUARIOS, O SACARLOS DE DICHA OPCION

LA FAMILIA SuiGenerisSearchCriteria_ ES LA QUE PERMITE MODIFICAR TODOS ESTOS PARAMETROS: AGREGAR O QUITAR TERMINOS DE BUSQUEDA,
AGREGAR O QUITAR UBICACIONES, SEGUIR O DEJAR DE SEGUIR USUARIOS, PONER USUARIOS EN "MUTE".

********************************************************************************************************************************/
-- //// ENDPOINT 47.
--SE IDENTIFICA LA SESION PRIMERO...
EXEC [dbo].[SuiGenerisSearchCriteria_Add_SearchWord]
	@UserID BIGINT
	, @NewWord NVARCHAR(100)
--DEVUELVE 
SELECT @Added AS Added --bool
	, @UserWordID AS UserWordID --int


-- //// ENDPOINT 48.
EXEC dbo.SuiGenerisSearchCriteria_Get_SearchWords
	@UserID BIGINT
--DEVUELVE
UserWordID --INT
, Word --STRING


-- //// ENDPOINT 49.
--SE IDENTIFICA LA SESION PRIMERO...
EXEC [dbo].[SuiGenerisSearchCriteria_Delete_SearchWord]
	@UserID BIGINT
	, @UserWordID INT
-- NO DEVUELVE NADA




-- //// ENDPOINT 50.
--SE IDENTIFICA LA SESION PRIMERO...
[dbo].[SuiGenerisSearchCriteria_Add_Location]
	@UserID BIGINT
	, @NewLocationString NVARCHAR(100)
--devuelve...
Added -------------------------------------------> bool	(true means added, false is not added)
, NotAddedBecause ---------------------> byte (if Add is true then NULL. Otherwise, 1 when the proposed location does not exist, or 2 in case user already covers the location)
, IfAddedRemoveOthers -------------> bool (NULL if not added. If a location is indeed added, then true to indicate other locations should be removed. Else false, no locations to delete)
, DeletionsXML --------------------------->	XML (NULL unless there are locations to remove. If locations do exist, then <DeleteUserRowID><UserRowID>12345</UserRowID><UserRowID>67890</UserRowID><UserRowID>34567</UserRowID></DeleteUserRowID>)
, NewLocation ----------------------------->  (In case Add = true, then there coul be any location string such as 'Los Angeles, CA, US'. Otherwise this will be NULL)
, NewUserLocationRowID ---------->  (In case Add = true, the id for this users new location, such as -232200)


-- //// ENDPOINT 51.
--SE IDENTIFICA LA SESION PRIMERO...
EXEC [dbo].[SuiGenerisSearchCriteria_Get_Locations]
	@UserID BIGINT
	, @LanguageID INT
--DEVUELVE
UserRowID --INT
, Location --STRING


-- //// ENDPOINT 52.
--SE IDENTIFICA LA SESION PRIMERO...
[dbo].[SuiGenerisSearchCriteria_Delete_Location]
	@UserID BIGINT
	, @UserRowID INT
-- NO DEVUELVE NADA






-- //// ENDPOINT 53.
--SE IDENTIFICA LA SESION PRIMERO...
[dbo].[SuiGenerisSearchCriteria_Get_IsUserFollowed]
	@UserID BIGINT,
	@TargetUserID BIGINT
--DEVUELVE 
UserIsFollowed --bool


-- //// ENDPOINT 54.
--SE IDENTIFICA LA SESION PRIMERO...
[dbo].[SuiGenerisSearchCriteria_Add_FollowedUser]
	@UserID BIGINT,
	@TargetUserID BIGINT


-- //// ENDPOINT 55.
--SE IDENTIFICA LA SESION PRIMERO...
[dbo].[SuiGenerisSearchCriteria_Get_FollowedUsers]
	@UserID BIGINT
--DEVUELVE
UserID, Name, Avatar
, IsMute, ShortenedNameFull, Slogan


-- //// ENDPOINT 56.
--SE IDENTIFICA LA SESION PRIMERO...
[dbo].[SuiGenerisSearchCritera_Change_MuteFollowedUser]
	@UserID BIGINT,
	@UserIDFollowed BIGINT


-- //// ENDPOINT 57.
--SE IDENTIFICA LA SESION PRIMERO...
[dbo].[SuiGenerisSearchCriteria_Change_UnMuteFollowedUser]
	@UserID BIGINT,
	@UserIDFollowed BIGINT
-- NO DEVUELVE NADA


-- //// ENDPOINT 58.
--SE IDENTIFICA LA SESION PRIMERO...
[dbo].[SuiGenerisSearchCriteria_Delete_FollowedUser]
	@UserID BIGINT,
	@TargetUserID BIGINT
-- NO DEVUELVE NADA




/********************************************************************************************************************************
FAMILIA: Notifications_

La mayoria de los sprocs de esta familia es llamada por otros sprocs y no son utilizados directamente en la API.
Aqui algunos de ellos documentados:
-Notifications_Reply_To_PostingUser_Create
-Notifications_Reply_To_RespondingUser_Create
-Notifications_Update_Agenda_Create
-Notifications_Update_Followers_Create
*******************************************************************************************************************************/

-- //// ENDPOINT 59.
--SE IDENTIFICA LA SESION PRIMERO...
EXEC dbo.Notifications_Get_SummaryOfNotifications
	@UserID BIGINT
--DEVUELVE 
NotificationTypeID --int
, CountOfNotifications --int


-- //// ENDPOINT 60.
--SE IDENTIFICA LA SESION PRIMERO...
EXEC [dbo].[Notifications_Delete_NotificationsOfNewFollowers]
	@UserID BIGINT
--NO DEVUELVE NADA


-- //// ENDPOINT 61.
--SE IDENTIFICA LA SESION PRIMERO...
EXEC [dbo].[Notifications_Delete_NotificationsInAgenda]
	@UserID BIGINT
--NO DEVUELVE NADA


-- //// ENDPOINT 62.
--SE IDENTIFICA LA SESION PRIMERO...
EXEC [dbo].[Notifications_Delete_ByNotificationID](
	@UserID BIGINT
	, @NotificationID BIGINT
)
--NO DEVUELVE NADA


/********************************************************************************************************************************
FAMILIA: OtherUsefulItems_

Esta familia de sprocs trae datos diversos, en su mayoria listas, de cosas muy distintas entre si en ocasiones.

Por ejemplo, listas de usuarios recomendados: la logica es que si los usuarios que siguen a este perfil y siguen a otro, 
se te va a ofrecer una lista de estos otros para que los veas.

Otro ejemplo, las monedas en las que se puede publicar el precio de algo.

No tienen relacion entre si estas cosas. Pero, para evitar un sin fin de clases vamos a agrupar algunos sprocs
bajo esta familia.

********************************************************************************************************************************/


-- //// ENDPOINT 63.
--SE IDENTIFICA LA SESION PRIMERO...
EXEC [dbo].[OtherUsefulItems_Get_ActiveCurrencies] 
	--SIN PARAMETROS
--DEVUELVE
CurrencyID --int
, CurrencyLabel --string


-- //// ENDPOINT 64.
--ESTE ENDPOINT ES TANTO PARA LA SECCION DE USUARIOS COMO PARA EL PUBLICO EN GENERAL
--SE IDENTIFICA LA SESION PRIMERO...
EXEC [dbo].[OtherUsefulItems_Get_ListOfRecommendedUsers]
	@UserID BIGINT = NULL --OMITIR PARA EL PUBLICO GENERAL
	, @VisitingUserID BIGINT
--DEVUELVE
UserID, Avatar, Name, TotalFollowers, Slogan



/********************************************************************************************************************************
FAMILIA: LocationSearch_

Hemos visto casos de familias cuyos endpoints estan entrelazados muy fuertemente, por ejemplo la familia LostPassword en que incluso son secuenciales.
En el caso de esta familia que ahora nos ocupa, LocationSearch, la interrelacion es mas dificil de percibir, asi que a continuacion intento explicarla...

Observemos que hay sprocs/endpoints de otras familias que toman un string con una posible ubicacion:
UserData_Add_Coverage tiene un parametro @Locationstring
SuiGenerisSearchCriteria_Add_Location tiene un parametro @NewLocationString

¿Cómo vamos a asegurarnos de que el usuario ingrese una buena cadena de caracteres que quede bien con alguna geografía y así obtener el resultado deseado?
Se le van a ofrecer listas de autocompletar, como sucede en Google y Facebook y la mayoría de sitios de buena calidad.

Pero no solo eso: la sección pública de la Web necesita cotejar constantemente ubicación+ip para dar resultados a los usuarios.
¿Por qué? Porque las listas de postings que se le envían a un usuario en la sección pública basan su geografía en la dirección IP, pero el usuario solo debe pensar en geografías.

Lista de Endpoints a crear:
Endpoint 1: (endpoint público) lista de autocompletar con sugerencias de ciudades (solo ciudades) para el público general. Esta lista devuelve solo ciudades.
Endpoint 2: (endpoint para sesiones) lista de autocompletar con sugerencias de geografías (a 3 niveles sea ciudad, estado o país).
Endpoint 3: (endpoint público) obtiene el nombre de la ciudad donde se encuentra el usuario por medio de su IP cuando se encuentra en la parte pública.
Endpoint 4: (endpoint público) cuando el mismo usuario se decide por un string de ciudad para hacer una búsqueda, este endpoint le da la geografía más exacta posible.
Endpoint 5: (endpoint público) obtiene una ip de la misma geografía que desea ver el usuario.

Descripción completa de los endpoints:
Todos los sprocs de los endpoints devuelven JSON prefabricado por SQL Server. Sin embargo, hay casos de endpoints que son para el público general y otros que son para sesión y por tanto requieren la "anotación" [ProtectedEndpoint].

Endpoint 1: no requiere [ProtectedEndpoint]
SPROC [dbo].[LocationSearch_Get_LocationSuggestionsList_CitiesOnly]
@LocationHint NVARCHAR(100)
DEVUELVE JSON PREFABRICADO
{"locations":[
{"location":"STRING"}

,
{"location":"STRING"}

,
{"location":"STRING"}

,
{"location":"STRING"}

]}

Endpoint 2: requiere [ProtectedEndpoint]
SPROC [dbo].[LocationSearch_Get_LocationSuggestionsList_AllLevels]
@LocationHint NVARCHAR(100)
DEVUELVE JSON PREFABRICADO
{"locations":[
{"location":"STRING"}

,
{"location":"STRING"}

,
{"location":"STRING"}

,
{"location":"STRING"}

]}

Endpoint 3: no requiere [ProtectedEndpoint]
SPROC [dbo].[LocationSearch_Get_CityStateCountryFromIP]
@IpAddress DECIMAL(38, 0)
, @IPAddressVersionID TINYINT
DEVUELVE JSON PREFABRICADO
{location:"STRING"}

Endpoint 4: no requiere [ProtectedEndpoint]
SPROC [dbo].[LocationSearch_Get_BestMatch_OnlyCityLevel]
@Locationstring NVARCHAR(100)
DEVUELVE JSON PREFABRICADO
{found:true/false,location:"STRING",locationNumber:"STRING"}

Endpoint 5: no requiere [ProtectedEndpoint]
SPROC [dbo].[LocationSearch_Get_IPAddressBasedOnCityName]
@SearchCity NVARCHAR(100)
DEVUELVE JSON PREFABRICADO
{ipAddress:"STRING",ipAddressVersion:"STRING"} 
********************************************************************************************************************************/




/********************************************************************************************************************************
FAMILIA: LostPassword_



Estos endpoints no necesitan la "anotacion" [ProtectedEndpoint],, puesto que trabajan del lado publico de la aplicacion.

Esta serie de endpoints ayudan a un usuario cuando pierde su password, e incluso su username.

La dinámica que operará entre estos endpoints es la siguiente:

Endpoint 1: Si el usuario no recuerda cual es su username, basta que ingrese su correo electrónico de contacto, y se le enviará un correo electrónico con el username. Esto aplica en la dinámica únicamente si el usuario no recuerda su username.

Endpoint 2: El usuario ingresa su username y recibe su pregunta de seguridad.

Endpoint 3: El usuario ingresa la respuesta a su pregunta de seguridad. Si la respuesta es correcta, entonces se le crea un token ligado a su userId. Este par de datos token-userId se ponen en un link en el cuerpo de un correo electrónico, para que el usuario acceda y haga clic ahí. El link lo llevará a una liga para cambiar su password.

Endpoint 4: este endpoint solamente identifica que el par de datos token-userId es válido para permitir al usuario acceder al link donde cambiará su password (en la base de datos habrá un proceso que expirará a los 15 minutos ese par token-userId)

Endpoint 5: permite al usuario cambiar el password. Debe primero identificar el par token-userId, para que luego el código pase a la sección del cambio. El sproc del cambio "quema" el token y lo vuelve inservible.

Descripción detallada de los Endpoints:

ENDPOINT 1: proveer username por correo electrónico en caso que el usuario no lo recuerde.
El usuario enviará su correo electrónico de contacto.

EXEC dbo.LostPassword_Get_Username_OnlyIfAccountIsActive
@Email AS NVARCHAR(100)
--DEVUELVE
Available --bool si es falso indica o que el correo esta mal o que la cuenta esta en un estatus no accesible y por lo tanto no se puede proceder
, Name --string
, Username --string
, EmailSubject --string
, EmailBody --string contiene un par de llaves 0 y 1 para sustituir por el nombre y el username
--CON ESTOS DATOS, EL ENDPOINT LE ENVIA UN CORREO ELECTRONICO

ENDPOINT 2: mostrarle al usuario la pregunta de seguridad

Basta que el usuario envíe su username y correo electrónico de contacto
EXEC dbo.LostPassword_Get_SecurityQuestion
@Username NVARCHAR(100)
@Email NVARCHAR(100)
--DEVUELVE
--JSON PREFABRICADO POR SQL, CON SU PREGUNTA.

ENDPOINT 3: Se verifica la respuesta a la pregunta, que de ser ccorrecta devuelve todo lo siguiente.
EXEC dbo.LostPassword_Validate_SecurityAnswer
@Username NVARCHAR(100)
, @Email NVARCHAR(100)
, @SecurityAnswer NVARCHAR(100)
--DEVUELVE
Correct --bool
, UserID --long
, Name --string
, EmailSubjectString --string
, EmailBodySting; --string

--Si responde correctamente, se crea un token sobre este cambio
EXEC [dbo].[LostPassword_Create_Token]
@UserID BIGINT
, @Token NVARCHAR(100)
Y entonces se envia el correo electrónico con el link

ENDPOINT 4: sirve solo para verificar que exista un userId con un token listo para hacer un cambio de password.
--Cambia su password y puede ingresar
EXEC [dbo].[LostPassword_Verify_TokenIsValid] (
@UserID BIGINT
, @Token NVARCHAR(100)
--DEVUELVE
Valid

ENDPOINT 5: realiza el cambio de password.
Hay qué identificar el token mas el userId
EXEC [dbo].[LostPassword_Verify_TokenIsValid] (
@UserID BIGINT
, @Token NVARCHAR(100)
--DEVUELVE
Valid --bool, en JSON PREFABRICADO POR SQL

Y entonces ya se puede realizar...
--Si Valid == true entonces se procede con:
EXEC [dbo].[LostPassword_Change_Password]
@UserID BIGINT
, @Token NVARCHAR(100)
, @NewPassword NVARCHAR(100)
--DEVUELVE
Changed --bool
--EL ENDPOINT DEVUELVE 200 OK, U OTRO EN CASO DE ERROR

********************************************************************************************************************************/

/********************************************************************************************************************************
FAMILIA UserPublicKey

Estos endpoints no necesitan el atributo ProtectedEndpoint
El UserPublicKey es un identificador alternativo de la cuenta de un usuario en donde se toman las palabras del "nombre de pluma" para tener un identificador mas reconocible para los humanos.

Al ingresar a algunas paginas de perfil de usuario, se pone el UserPublicKey en los parametros de la URL.

Lo unico que esta familia hace es utilizar el UserPublicKey para intercambiarlo por el UserID, o viceversa.
una vez teniendo una llave o la otra se pueden hacer otras cosas como llamar a otros endpoints de la API.

ENDPOINT 1
Devuellve el UserPublicKey a partir del UserID
UserPublicKey_Get_UserPublicKey
@UserID BIGINT
Devuelve JSON prefabricado por SQL Server

{userPublicKey:string}

ENDPOINT 2
Devuelve el userID a partir de UserPublicKey
UserPublicKey_Get_UserID
@UserPublicKey NVARCHAR(200)
Devuelve JSON prefabricado por SQL Server

{userId:string}

**************************************/








/********************************************************************************************************************************
FAMILIA Hashtags

Estos postings son para la parte publica y no requieren el atributo ProtectedEndpoint

Toda la funcionalidad de recopilacion de hashtags se hace en la familia Postings.
Se recopilan cuando un usuario publica un posting y tambien cuando lo edita.
En esta API los hashtags sirven para crear categorias de productos disponibles al publico.
En vez de encasillar al usuario en ciertas listas, aqui se le da privilegio a los hashtags que el usuario decida utilizar para crear las categorias.

Esta familia de sprocs solo muestra las categorias en la parte publica para darle organizacion a la informacion.

ENDPOINT 1
Devuelve los 5 principales hashtags para una letra inicial
Hashtags_Get_ListOfHashtagsForGeography
@IPAddress DECIMAL(38, 0)
, @IpAddressProtocol TINYINT
, @StartingLetter NVARCHAR(10) = NULL
, @OnlyTopFive BIT = 0
Devuelve JSON prefabricado por SQL Server
{"hashtags":[

{ hashtagStartingLetter:string , hashtag:string , rankInStartingLetter:int , HashtagsInStartingLetter:int , Hotness:real }

,

{ hashtagStartingLetter:string , hashtag:string , rankInStartingLetter:int , HashtagsInStartingLetter:int , Hotness:real }

,

{ hashtagStartingLetter:string , hashtag:string , rankInStartingLetter:int , HashtagsInStartingLetter:int , Hotness:real }

,
...
...
]}

ENDPOINT 2
Devuelve una lista arbitraria de los hashtags con mas trafico, para exponerla a los usuarios en el front end
Hashtags_Get_TopTrending
@IPAddress DECIMAL(38, 0)
, @IpAddressProtocol TINYINT
Devuelve JSON prefabricado por SQL Server
{"hashtags":[

{ hashtag:string , image:string }

,

{ hashtag:string , image:string }

,

{ hashtag:string , image:string }

,
...
...
]}
**************************************/


/********************************************************************************************************************************
FAMILIA SuiGenerisSearchCriteria

Todos estos endpoints necesitan el atributo ProtectedEndpoint, pues pertenecen al ambito de usuario en sesion.

La familia SuiGenerisSearchCriteria representa las busquedas especializadas que pueden hacer los usuarios.
Un usuario puede tener dados de alta
N palabras clave de busqueda.
N ubicaciones de interes.
N usuarios a los que sigue.

Sus resultados de busqueda corresponderian a la interseccion de pablabras-ubicaciones en union a los postings de las personas a las que sigue.
Resulta sumamente interesante pues, por ejemplo, supongamos que vas a hacer la fiesta de uno de tus hijos. Entonces puedes poner de palabras de busqueda:

    Payaso
    Mago
    Dulces
    fiesta
    show infantil
    Pasteles

En las ubicaciones:

    Monterrey
    Santa Catarina
    San Nicolas
    Apodaca
    Escobedo
    San Pedro
    Garcia

Y te va a dar TODO lo que buscas para rapidamente armar tu fiesta, o cualquier proyecto que quieras hacer. Ademas, siempre puedes darle FOLLOW a los anunciantes para que te sigan apareciendo sus anuncios.
Si el anunciante te interesa en el fondo, pero de momento no quieres que te aparezcan sus anuncios puedes darle Mute y ya esta: el anunciante se queda en tu agenda de usuarios que sigues pero no te aparecen sus anuncios.
POR LO TANTO, Y EN RESUMEN, esta familia de sprocs sirve para controlar todos los aspectos de las busquedas de usuarios inscritos en la aplicacion:

DESCRIPCION DE ENDPOINTS

ENDPOINT 1
Te da la lista de palabras de busqueda que tienes dadas de alta:
SuiGenerisSearchCriteria_Get_SearchWords
@UserID BIGINT
Devuelve JSON prefabricado por SQL Server
{"searchWords":[

{userWordId:int , word:string}

,

{userWordId:int , word:string}

,

{userWordId:int , word:string}

,
...
...
]}

ENDPOINT 2
Te da la lista de las ubicaciones que tienes dadas de alta
SuiGenerisSearchCriteria_Get_Locations
@UserID BIGINT
, @LanguageID INT
Devuelve JSON prefabricado por SQL Server
{"searchLocations":[

{ searchLocationId:int , location:string }

,

{ searchLocationId:int , location:string }

,

{ searchLocationId:int , location:string }

...
...
]}

ENDPOINT 3
Cuando entres al perfil de un usuario, este endpoint te dice si eres su seguidor
SuiGenerisSearchCriteria_Get_IsUserFollowed
@UserID BIGINT,
@TargetUserID BIGINT
Devuelve JSON prefabricado por SQL Server

{userIsFollowed:bool}

ENDPOINT 4
Te da la lista de usuarios que sigues, asi como otros datos (si lo tienes en mute, por ejemplo)
SuiGenerisSearchCriteria_Get_FollowedUsers
@UserID BIGINT
Devuelve JSON prefabricado por SQL Server
{"usersFollowed":[

{userId:int , name:string , avatar:string , isMute:bool , userPublicKey:string , slogan:string }

,

{userId:int , name:string , avatar:string , isMute:bool , userPublicKey:string , slogan:string }

,

{userId:int , name:string , avatar:string , isMute:bool , userPublicKey:string , slogan:string }

,

{userId:int , name:string , avatar:string , isMute:bool , userPublicKey:string , slogan:string }

,
...
...
]}

ENDPOINT 5
Agrega una palabra de busqueda para el usuario
SuiGenerisSearchCriteria_Add_SearchWord
@UserID BIGINT
, @NewWord NVARCHAR(100)
Devuelve JSON prefabricado por SQL Server

{ added:bool , userWordID:int }

ENDPOINT 6
Agrega una ubicacion de busqueda para el usuario
SuiGenerisSearchCriteria_Add_Location
@UserID BIGINT
, @NewLocationString NVARCHAR(100)
Devuelve JSON prefabricado por SQL Server
{
added:bool
, notAddedBecause:int
, ifAddedRemoveOthers:bool
, deletions:[

{searchLocationId:int}

,

{searchLocationId:int}

,

{searchLocationId:int}

...
...
]
,location:string
,searchLocationId:int
}

ENDPOINT 7
Hace que un usuario siga a otro
SuiGenerisSearchCriteria_Add_FollowedUser
@UserID BIGINT,
@TargetUserID BIGINT
No devuelve nada (200 ok)

ENDPOINT 8
Le quita el "mute" a un usuario que este mismo usuario sigue
SuiGenerisSearchCriteria_Change_UnMuteFollowedUser
@UserID BIGINT,
@UserIDFollowed BIGINT
No devuelve nada (200 ok)

ENDPOINT 9
Le pone el "mute" a un usuario que este mismo usuario sigue
SuiGenerisSearchCritera_Change_MuteFollowedUser
@UserID BIGINT,
@UserIDFollowed BIGINT
No devuelve nada (200 ok)

ENDPOINT 10
Elimina una palabra/termino de busqueda
SuiGenerisSearchCriteria_Delete_SearchWord
@UserID BIGINT
, @UserWordID INT
No devuelve nada (200 ok)

ENDPOINT 11
Elimina una ubicacion de busqueda
SuiGenerisSearchCriteria_Delete_Location
@UserID BIGINT
, @UserRowID INT
No devuelve nada (200 ok)

ENDPOINT 12
hace que dejes de seguir a un usuario/anunciante
SuiGenerisSearchCriteria_Delete_FollowedUser
@UserID BIGINT,
@TargetUserID BIGINT
No devuelve nada (200 ok)

**************************************/



/********************************************************************************************************************************
FAMILIA SystemBooting

Este es un solo endpoint con un solo sproc que sirve para los dispositivos smart.
No ocupa ProtectedEndpoint ni nada por el estilo.
Se hace hincapie en "dispositivos smart" porque no sabemos todavia si se requerira en algun futuro una aplicacion para smart TV, aunque en la practica solo tenemos celulares en mente.

El objetivo es indicarle al dispositivo si su aplicacion esta vigente o necesita renovarse.
En el caso extremo de que no este vigente se le debe negar el servicio, o darle un aviso si existe un mensaje.

SystemBooting_Get_DeviceVersionStatus
@DeviceID INT marca/sistema del dispositiivo
, @DeviceVersionID INT version del software del dispositivo
, @LanguageID INT idioma
Devuelve json prefabricado por SQL Server

{isToBeDeprecated:bool, isDeprecated:bool, serviceMessage:string}

Un DeviceID representa por ejemplo, el iPhone.
Aunque puede representar tambien la generalidad de los Android.

Un DeviceVersionID podria representar, por ejemplo, cualquier edicion del iPhone (5, 6, 7, X)
O diferentes versiones de Android (KitKat, JellyBeans, etc)

Los distintos dispositivos tendrian en su programa unas constantes que indicarian su DeviceID y su DeviceVersionID, mismas que tendrian que ser enviadas por el endpoint cuando sea iniciada la aplicacion y si poder ver el estatus de la misma.

**************************************/




/********************************************************************************************************************************
FAMILIA SearchWords 

Aqui solo hay un endpoint y un solo sproc.
Se trata de:

SearchWords_Get_ListOfLikeSearchWords
string @Argument NVARCHAR(100)
Devualve JSON prefabricado por SQL Server
{"searchWords":[

{"word":string}

,

{"word":string}

,

{"word":string}

...
...
]}
Devuelve una lista de sugerencias topada a 8 (podria cambiar) basadas en lo que el usuario esta escribiendo.
Es para autocompletar el articulo o servicio que busca el usuario.

**************************************/




/********************************************************************************************************************************
FAMILIAS Reportabure y ReportPublic

Es posible que los usuarios deban reportar un comportamiento o posting inadecuado.
Un reporte conlleva muchas cosas, por ejemplo:

    cual es el tipo de objeto que se esta reportando: un posting, un producto, un usuario.

    Debe llevar una categoria.

    Debe llevar un texto de lo que dice el posting (si es un posting)

    Debe llevar las imagenes

    ...entre otros

Cuando se va a comenzar a realizar un reporte, el usuario debe elegir un "tema" del reporte.
para ello se le presenta una lista con categorias por medio del sproc ReportAbuse_Get_ReportOptions.

Luego, SI Y SOLO SI, se trata de un reporte para el publico general:

    Se debe generar una captcha por medio de ReportPublic_Add_Captcha, misma que arroja una reportCaptchaId.

    Si el usuario no puede leer la captcha, puede cambiarla con ReportPublic_Change_CaptchaCode

    Al querer ingresar el reporte, tiene que identificar la captcha bien por medio de ReportPublic_Get_CaptchaIsAccurate. Si la captcha esta correcta entonces se debe eliminar por medio de ReportPublic_Delete_Captcha y se debe ingresar el reporte por medio de ReportAbuse_Add_Report

SI EL USUARIO ESTA EN SESION, no es necesario nada de la captcha, y solo se necesita proceder con ReportAbuse_Add_Report

Descripcion de endpoints

ENDPOINT 1 (2 formas, uno publico y otro en sesion)
ReportAbuse_Get_ReportOptions
Estas son las opciones de las cuales puede elegir el usuario para realizar un reporte. Generalmente no seran mas de 5, pero queremos que esto este atado a un endpoint por si cambian.
Notese que esta atado a un idioma (1 para ingles) mismo que depende del idioma de la aplicacion o de la version de la web.
PARAMETROS
INT @LanguageID
Devuelve json prefabricado por SQL Server
{"reportOptions":[

{reportTypeID:int,reportType:string}

,

{reportTypeID:int,reportType:string}

,

{reportTypeID:int,reportType:string}

,
...
...
]}

En cuanto el usuario, sin sesion, es decir al publico, pida crear un reporte, se le debe crear un captcha para que tenga que identificar antes de enviar el correo.
se le enviara el ID de captcha de vuelta.
ReportPublic_Add_Captcha
PARAMETROS
String @Captcha
En este

{reportCapthaTokenID:"string"}

ENDPOINT 2 (solo para el publico en general)
Se necesita un endpoint que devuelva la imagen de la captcha. Para ello se debe obtener la captcha mediante el
Id y con ello se debe dibuujar.
ReportPublic_Get_CaptchaByReportCapthaTokenID
@CaptchaID BIGINT
DEVUELVE
imagen jpg

ENDPOINT 3 (solo para el publico en general)
Si el usuario no puede identificar la captcha, se le puede recrear por medio de C#, misma que tendria que pedir de nuevo mediante el endpoint anterior
ReportPublic_Change_CaptchaCode
@CaptchaID BIGINT
, @NewCaptcha VARCHAR(7)
DEVUELVE
nada (200 ok)

ENDPOINT 4 (2 formas, uno publico y otro en sesion)
Cuando se halla del lado publico, si el usuario ingresa el reporte, debe hacerlo incluyendo las letras del captcha.
ReportPublic_Get_CaptchaIsAccurate
@CaptchaID BIGINT
, @Captcha VARCHAR(7)

si el captcha fuese correcto, hay que quemarlo/eliminarlo. De lo contrario, devolver algun error.
ReportPublic_Delete_Captcha
@CaptchaID BIGINT

Y finalmente ingresar el reporte
ReportAbuse_Add_Report
byte @ObjectTypeID TINYINT
long @IDOfObjectBeingReported BIGINT
smallint @ReportTypeID SMALLINT
long @ReportingUserID BIGINT = NULL (omitir para la parte publica)
string @ReportingUserMessageHint NVARCHAR(500)
long @PostingIDForReportFollowUp BIGINT
string @ReportedItemTitle NVARCHAR(100)
string @ReportedItemQuote NVARCHAR(100)
string @ReportedItemMessage NVARCHAR(4000)
string @ImagesString NVARCHAR(4000) = NULL
bool @BanUser BIT = NULL (omitir para la parte publica)

**************************************/




/********************************************************************************************************************************
FAMILIA Notifications

Todos estos endpoints son para usuarios en sesion, es decir [ProtectedEndpoint]
Las notificaciones son simbolos que aparecen alrededor de la aplicacion o del sitio web indicandonos algun tipo de actividad.
El tipo de acciones que generan notificaciones son:

    Cuando comienzo a seguir a un usuario se genera una notificacion para mi mismo, de forma que cado "equis" segundos se vea si se tiene que regargar mi lista de personas a las que sigo.
    Cuando respondo a un posting se genera una notificacion para el usuario que genero el posting.
    Cuando responden a un posting mio o a un posting que yo conteste, entonces las notificaciones se generan para mi.

Todas estas notificaciones se generan a partir de otros endpoints y estan bien enrraizadas en sus propios sprocs.
Sin embargo, la eliminacion de estas notificaciones (una vez que se han visto los postings o las respuestas) depende directamente de que se lance una llamada a algun endpoint para eliminarla.

Esta familia se compone de endpoints que nos dan las notificaciones en modo general (cuantas notificaciones y de que tipo) o los endpoints para eliminarlas.

Descripcion:

Notifications_Get_SummaryOfNotifications
PARAMETROS
LONG @UserID : el usuario del cual se que quieren recuperar el resumen de notificaciones.
Devuelve JSON prefabricado por SQL Server
La idea es que cada 40 segundos aproximadamente se llame a este endpoint para ver que notificaciones de "caracter general" se deben mostrar. Cuando hay notificaciones, y estas pertenecen a otra vista de la GUI, entonces se accionara una imagen que denote que hay actividad en dicha pantalla.
Los tipos de notificaciones son 4:

    Determina si mi agenda de personas que sigo debe actualizarse. No genera alerta visible, solo deberia en consecuencia actualizarse la lista.
    Un usuario me empezo a seguir o me dejo de seguir. No genera alerta visible, en consecuencia deberia mandar a actualizar mi numero de seguidores
    Alguien contesto a una conversacion de un posting mio. Si no estoy en la pantalla correspondiente, debe generarse una imagen de una notificacion en el link a dicha pagina
    Alguien contesto a una conversacion de un posting que yo habia contestado. Si no estoy en la pantalla correspondiente, debe generarse una imagen de una notificacion en el link a dicha pagina

ejemplo del json:
{"notifications":[
{notificationTypeId:1,countOfNotifications:int}

,
{notificationTypeId:2,countOfNotifications:int}

,
{notificationTypeId:3,countOfNotifications:int}

,
{notificationTypeId:4,countOfNotifications:int}

]}

Notifications_Delete_NotificationsInAgenda
PARAMETROS
Long @UserID
NO DEVUELVE NADA (200 OK)
Elimina las notifications de tipo 1 (nuevas personas que sigo)

Notifications_Delete_NotificationsOfNewFollowers
PARAMETROS
Long @UserID
NO DEVUELVE NADA (200 OK)
Elimina las notifications de tipo 2 (nuevos seguidores que tengo)

Notifications_Delete_ByNotificationID
PARAMETROS
Long @UserID
Long @NotificationID
NO DEVUELVE NADA (200 OK)
Sirve para eliminar las notificaciones enrraizadas en un posting, como las respuestas por ejemplo.
No es necesario diferenciar entreo los tipos 3 y 4 donde yo respondo o me responden, ya que se basa en el ID de la notificacion.

**************************************/




/********************************************************************************************************************************
FAMILIA OtherUsefulItems

La familia OtherUsefulItems es solo un titulo para un par de sprocs que no caben en otros casos.
Uno de ellos tiene uso tanto para el publico general como en modo ProtectedEndpoint (OtherUsefulItems_Get_ListOfRecommendedUsers). El otro es exclusivamente protected endpoint (OtherUsefulItems_Get_ActiveCurrencies)

*Descripcion: *

OtherUsefulItems_Get_ListOfRecommendedUsers:
Devuelve JSON prefabricado por SQL Server
PARAMETROS
long @UserID BIGINT: es el usuario que esta en sesion. Se omite para la parte publica.
long @VisitingUserID BIGINT es el id usuario cuyo perfil esta siendo visitado.

Cuando visitas el perfil de un usuario para ver su informacion, este endpoint te proporciona una lista de otros usuarios recomendados. Dicha recomendacion esta basado en los usuarios que siguen aquellos que siguen a este mismo.

Ejemplo: estoy visitando al usuario A, que tiene 1000 seguidores.
estos 1000 seguidores, a quien siguen? Pues a B con 800 de ellos, a C con 300, a D con 180 ....
Entonces la lista Arroja a B, C, D, hasta 8 de ellos en orden descendente
Cuando se consulta como usuario (sin omitir el parametro @UserID) se omiten de la lista aquellos usuarios que ya son seguidos por este mismo
{"users":[
{userId:int,avatar:string,name:string,totalFollowers:int,slogan:string}
,{userId:int,avatar:string,name:string,totalFollowers:int,slogan:string}
,{userId:int,avatar:string,name:string,totalFollowers:int,slogan:string}
,{userId:int,avatar:string,name:string,totalFollowers:int,slogan:string}
...
...
]}

OtherUsefulItems_Get_ActiveCurrencies
Devuelve JSON prefabricado por SQL Server
SIN PARAMETROS
Este endpoint es para usar con modo ProtectedEndpoint
Simplemente provee una lista de monedas de distintos paises para poder crear postings o productos en tu perfil
ejemplo de respuesta:

{"currencies":[
{currencyId:int,currencyLabel:string},
{currencyId:int,currencyLabel:string},
{currencyId:int,currencyLabel:string}
...
...
]}

**************************************/

























/************************************************************************************************

ETAPA III

PROBAR LOS SPROCS DE DATOS DE USUARIO

************************************************************************************************/


--////ENDPOINT 7
--AGREGAR UN WEBSITE A LA LISTA DE WEBSITES DEL USUARIO
--SE IDENTIFICA LA SESION...

EXEC [dbo].[UserData_Add_Website](
	@UserID BIGINT
	, @Website NVARCHAR(100)
-- DEVUELVE UNA COLUMNA CON UN VALOR LONG
WebsiteID




--////ENDPOINT 8
--AGREGAR UN TELEFONO A LA CUENTA
--SE IDENTIFICA LA SESION...

EXEC [dbo].[UserData_Add_PhoneNumber](
	@UserID BIGINT
	, @PhoneNumber NVARCHAR(20)
-- DEVUELVE UNA COLUMNA CON UN VALOR LONG
PhoneNumberID





--////ENDPOINT 9
--AGREGAR UNA DIRECCION
--SE IDENTIFICA LA SESION...

EXEC [dbo].[UserData_Add_Address] (
	@UserID BIGINT
	, @Address NVARCHAR(100)
-- DEVUELVE UNA COLUMNA CON UN VALOR LONG
AddressID






--////ENDPOINT 10
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




--////ENDPOINT 11
--AGREGAR UNA IMAGEN A LA CUENTA DEL USUARIO.
--SE IDENTIFICA LA SESION...
--EN ESTE CASO, EL ENDPOINT DEBE HABER TOMADO DEL USUARIO LA IMAGEN, HABERLA CONVERTIDO EN UN 
--ARCHIVO, CON UN NUMBRE UNICO CALCULADO (UN GUID PROBABLEMENTE) Y PASAR ESE NOMBRE A 
--ESTE SPROC PARA QUE QUEDE REGISTRADA
EXEC [dbo].[UserData_Add_Image](
	@UserID BIGINT
	,@FileName VARCHAR(200)
--NO DEVUELVE NADA



--////ENDPOINT 12
--DECUELVE TODAS LAS IMAGENES DE LA CUENTA PARA QUE EL USUARIO PUEDA UTILIZARLAS EN 
--CREACION DE POSTINGS, PRODUCCTOS O CONTESTACIONES
[dbo].[UserData_Get_Images](
	@UserID BIGINT
)
AS
--DEVUELVE TABLA CON DOS COLUMNAS
ImageID --LONG
, [Image] --STRING




--////ENDPOINT 13
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





--////ENDPOINT 14
--ELIMINAR UNA DIRECCION
--SE IDENTIFICA LA SESION...

EXEC [dbo].[UserData_Delete_Address]
	@UserID BIGINT
	, @AddressID BIGINT
--NO DEVUELVE NADA


--////ENDPOINT 15
--ELIMINAR UN WEBSITE DE LA LISTA
--SE IDENTIFICA LA SESION...

EXEC [dbo].[UserData_Delete_Website]
	@UserID BIGINT
	, @WebsiteID BIGINT
--NO DEVUELVE NADA




--////ENDPOINT 16
--ELIMINAR UN NUMERO TELEFONICO
--SE IDENTIFICA LA SESION...

EXEC [dbo].[UserData_Delete_PhoneNumber]
	@UserID BIGINT
	, @PhoneNumberID BIGINT
--NO DEVUELVE NADA



--////ENDPOINT 17
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





--////ENDPOINT 18
--ELIMINAR COBERTURA
--SE IDENTIFICA LA SESION...
EXEC [dbo].[UserData_Delete_Coverage]
	@UserID BIGINT
	, @CoverageID BIGINT
--NO DEVUELVE NADA



--////ENDPOINT 19
--ELIMINAR UN PRODUCTO, YA NO ESTARA EN LA LISTA
--SE IDENTIFICA LA SESION...
EXEC [dbo].[UserData_Delete_Product]
	@UserID BIGINT,
	@ProductID BIGINT
--NO DEVUELVE NADA









--////ENDPOINT 20
--Cambiar la imagen de Avatar del usuario
--SE IDENTIFICA LA SESION...
EXEC [dbo].[UserData_Change_AvatarImageURL]
	@UserID BIGINT
	, @AvatarImageURL VARCHAR(200)




--////ENDPOINT 21
--cambiar la imagen de fondo del perfil de usuario
--SE IDENTIFICA LA SESION...
EXEC dbo.UserData_Change_BackgroundImageURL
	@UserID BIGINT
	, @BackgroundImageURL VARCHAR(100)



--////ENDPOINT 22
--cambiar el nombre del negocio, o bien, nombre publico del usuario
--SE IDENTIFICA LA SESION...
EXEC dbo.UserData_Change_Name
	@UserID BIGINT
	, @Name NVARCHAR(100)


--////ENDPOINT 23
--cambiar el slogan del negocio
--SE IDENTIFICA LA SESION...
EXEC dbo.UserData_Change_Slogan
	@UserID BIGINT
	, @Slogan NVARCHAR(100)


--////ENDPOINT 24
--cambiar preferencia de usuario sobre si recibir notificaciones por correo cuando le dan reply a sus propios postings
--SE IDENTIFICA LA SESION...
EXEC dbo.UserData_Change_SendEmailWhenTheyReplyToMyPostings
	@UserID BIGINT
	, @SendEmailWhenTheyReplyToMyPostings BIT


--////ENDPOINT 25
--cambiar la descripcion general del negocio o usuario
--SE IDENTIFICA LA SESION...
EXEC dbo.UserData_Change_BusinessDescription
	@UserID BIGINT
	, @BusinessDescription NVARCHAR(500)


--//ENDPOINT 26
--cambiar sexo (anyone can misclick right?)
--SE IDENTIFICA LA SESION...
EXEC dbo.UserData_Change_Gender
	@UserID BIGINT
	, @GenderID TINYINT



--////ENDPOINT 27
--cambiar el lenguage principal del usuario.
--SE IDENTIFICA LA SESION...
EXEC dbo.UserData_Change_Language
	@UserID BIGINT
	, @LanguageID INT



--////ENDPOINT 28
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



--////ENDPOINT 29
--cambiar preferencia de usuario sobre si recibir notificaciones cuando contestan a sus contestaciones sobre otros postings
--SE IDENTIFICA LA SESION...
EXEC dbo.UserData_Change_SendEmailWhenTheyReplyToMyReplies
	@UserID BIGINT
	, @SendEmailWhenTheyReplyToMyReplies BIT


--////ENDPOINT 30
--cambiar preferencia de usuario sobre si recibir newsletter
--SE IDENTIFICA LA SESION...
EXEC dbo.UserData_Change_SendEmailWithNewsletter
	@UserID BIGINT
	, @SendEmailWithNewsletter BIT










-- //// ENDPOINT 31. OBTENER INFORMACION GENERAL DE LA CUENTA DEL USUARIO:
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





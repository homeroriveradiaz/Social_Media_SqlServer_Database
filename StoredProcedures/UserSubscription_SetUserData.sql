USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Subscriber_AddUserData]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.UserSubscription_SetUserData', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserSubscription_SetUserData AS SELECT 1;');
END;
GO

ALTER PROCEDURE [dbo].[UserSubscription_SetUserData](
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
	--, @CaptchaID BIGINT --La captcha necesita confirmarse como medida de seguridad en el proximo endpoint
	--, @Captcha VARCHAR(50) --La captcha necesita confirmarse como medida de seguridad en el proximo endpoint
)
AS



DECLARE @CountryID INT
	, @StateID INT
	, @CityId INT
	, @NewUserLocationRowID INT = -2147483648
	, @CurrencyCount INT
	, @CurrencyID INT
	, @DefaultSlogan NVARCHAR(100) = dbo.fn_default_slogan_for_languageid(@LanguageID)
	, @DefaultBusinessDescription NVARCHAR(500) = dbo.fn_default_businessdescription_for_languageid(@LanguageID);


BEGIN TRANSACTION;
BEGIN TRY


	--FIRST, GET THE BASE LOCATION BASED ON THE IP ADDRESS
	EXEC dbo.LocationSearch_Get_LocationBasedOnIP
		@IpAddress = @IpAddress
		, @IPAddressVersion = @IPAddressVersion
		, @CountryID = @CountryID OUTPUT
		, @StateID = @StateID OUTPUT
		, @CityID = @CityId OUTPUT;


	--SECOND, CREATE A FIRST USER LOCATION FOLLOWED BASED ON THE PREVIOUS FINDING
	INSERT INTO dbo.User_LocationsFollowed 
	VALUES (@UserID, @NewUserLocationRowID, @CountryID, @StateID, @CityID);
	

	--THIRD, GET THE CURRENCY THAT BELONGS THERE 
	SELECT @CurrencyCount = COUNT(*)
	FROM dbo.CurrenciesGeography WITH(NOLOCK)
	WHERE CountryID = @CountryID
		AND Active = 1;


	IF (@CurrencyCount = 1) BEGIN	

		SELECT @CurrencyID = currencyID
		FROM dbo.CurrenciesGeography WITH(NOLOCK)
		WHERE CountryID = @CountryID
			AND Active = 1;

	END ELSE IF (@CurrencyCount > 1) BEGIN

		SELECT @CurrencyID = CurrencyID
		FROM dbo.CurrenciesGeography WITH(NOLOCK)
		WHERE CountryID = @CountryID
			AND StateID = @StateID
			AND Active = 1;

	END ELSE BEGIN
		--SET USD BY DEFAULT
		SET @CurrencyID = 2;

	END;



	UPDATE dbo.Users
	SET Name = @PenName
		, Slogan = @DefaultSlogan
		, BusinessDescription = @DefaultBusinessDescription
		, DateOfBirth = @DateOfBirth
		, Gender = @Gender
		, SecurityQuestion = @SecurityQuestion
		, SecurityAnswer = @SecurityAnswer
		, ContactEmail = @ContactEmail
		, BaseCountryID = @CountryID
		, BaseStateID = @StateID
		, BaseCityID = @CityId
		, SendEmailWhenTheyReplyToMyReplies = @SendEmailWhenTheyReplyToMyReplies
		, SendEmailWhenTheyReplyToMyPostings = @SendEmailWhenTheyReplyToMyPostings
		, SendEmailWithNewsletter = @SendEmailWithNewsletter
		, DefaultLanguageID = @LanguageID
		, DefaultCurrencyId = @CurrencyID
		, LastVisitingSectionID = 5 -- 5 is the Session Search page
	WHERE UserID = @UserID;



	--CREATE A PUBLIC KEY
	INSERT INTO dbo.UsersPublicKey (UserID, ShortenedName)
	VALUES (@UserID, REPLACE(REPLACE(@PenName, ' ', '.'), '&', 'n'));

	UPDATE dbo.UsersPublicKey
	SET ShortenedNameFull = ShortenedName + CAST(ShortenedNameID AS NVARCHAR)
	WHERE UserID = @UserID;



	--CONFIRM THE CAPTCHA, SO THIS CAN BE USED IN THE NEXT STEP
	--UPDATE dbo.CaptchaUserRelationship 
	--SET Identified = 1
	--WHERE CaptchaID = @CaptchaID 
	--	AND UserID = @UserID 
	--	AND Captcha = @Captcha;


END TRY
BEGIN CATCH

	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRANSACTION;
	END;
	
	THROW;

END CATCH;


IF @@TRANCOUNT > 0 BEGIN
	COMMIT TRANSACTION;
END;


GO




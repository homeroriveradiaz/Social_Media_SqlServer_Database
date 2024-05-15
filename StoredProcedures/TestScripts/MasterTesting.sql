



BEGIN TRANSACTION

BEGIN TRY

	


--ALTER PROCEDURE [dbo].[UserSubscription_ReserveUsernameAndPassword](
--	@Username NVARCHAR(100)
--	, @Password NVARCHAR(100)
--)
EXEC [dbo].[UserSubscription_ReserveUsernameAndPassword]
	@Username = N'katsuhirootomo'
	, @Password = N'abc12345';
--	{"created":true,"newUserId":-8999999999999999988}




--ALTER PROCEDURE [dbo].[UserSubscription_RegisterSubscriptionToken] (
--	@UserID BIGINT,
--	@Token NVARCHAR(100)
--)
EXEC [dbo].[UserSubscription_RegisterSubscriptionToken]
	@UserID = -8999999999999999988,
	@Token= N'APRTYUCJSUTIROOO';




--ALTER PROCEDURE [dbo].[UserSubscription_StoreNewCaptcha](
--	@UserID BIGINT
--	, @Captcha VARCHAR(50)
--)
EXEC [dbo].[UserSubscription_StoreNewCaptcha]
	@UserID = -8999999999999999988
	, @Captcha = N'ABCDEF';
--{"created":true,"captchaId":-8999999999999999996}









END TRY
BEGIN CATCH

	IF @@TRANCOUNT > 0 BEGIN
		ROLLBACK TRANSACTION;
		PRINT 'TRANSACTION HAS BEEN ROLLED BACK';
	END;


	DECLARE @Line INT = ERROR_LINE()
		, @Severity INT = ERROR_SEVERITY()
		, @Message VARCHAR(300) = ERROR_MESSAGE()
		, @Procedure VARCHAR(100) = ERROR_PROCEDURE();

	SET @Message = 'Line ' + CAST(@Line AS VARCHAR) + ', procedure ''' + ISNULL(@Procedure, '(none)') + '''. ' + @Message;

	RAISERROR(@Message, @Severity, 1);



END CATCH;



IF @@TRANCOUNT > 0 BEGIN

	COMMIT TRANSACTION;
	PRINT N'DATA HAS BEEN COMMITED';

END;




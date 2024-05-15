USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[ReportAbuse_EnterReport]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.ReportAbuse_Add_Report', N'P') IS NULL BEGIN
	EXEC('CREATE PROC dbo.ReportAbuse_Add_Report AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[ReportAbuse_Add_Report](	
	@ObjectTypeID TINYINT
	, @IDOfObjectBeingReported BIGINT
	, @ReportTypeID SMALLINT
	, @ReportingUserID BIGINT = NULL
	, @ReportingUserMessageHint NVARCHAR(500)
	, @PostingIDForReportFollowUp BIGINT
	, @ReportedItemTitle NVARCHAR(100)
	, @ReportedItemQuote NVARCHAR(100)
	, @ReportedItemMessage NVARCHAR(4000)
	, @ImagesString NVARCHAR(4000) = NULL
	, @BanUser BIT = NULL
)	
AS	


/************* PARTE 1. CREAR EL REPORTE ************/
DECLARE @AbuseReportID BIGINT
	, @ReportedUserID BIGINT;


INSERT INTO dbo.AbuseReports (ObjectID, IdOfObjectBeingReported, ReportTypeID
	, ReportingUserID, ReportingUserMessageHint, ReportDate, PostingIDForReportFollowUp
	, ReportedItemTitle, ReportedItemQuote, ReportedItemMessage, Active
)
VALUES (@ObjectTypeID, @IDOfObjectBeingReported, @ReportTypeID
		, @ReportingUserID, @ReportingUserMessageHint, GETDATE(), @PostingIDForReportFollowUp
		, @ReportedItemTitle, @ReportedItemQuote, @ReportedItemMessage, 1);
	

SET @AbuseReportID = SCOPE_IDENTITY();
	

IF (@ObjectTypeID = 1) BEGIN--POSTING 

	SELECT @ReportedUserID = PostedByUserID
	FROM dbo.Postings WITH(NOLOCK)
	WHERE PostingID = @IDOfObjectBeingReported;
	
	INSERT INTO dbo.AbuseReports_Assets(AbuseReportID, Asset)
	SELECT @AbuseReportID, Items
	FROM dbo.fn_break_string_in_brackets(@ImagesString);

END; ELSE IF (@ObjectTypeID = 2) BEGIN--PRODUCT

	SELECT @ReportedUserID = UserID
	FROM dbo.Products WITH(NOLOCK)
	WHERE ProductID = @IDOfObjectBeingReported;

END; ELSE IF (@ObjectTypeID = 3) BEGIN --USER

	SET @ReportedUserID = @IDOfObjectBeingReported;

END;
	
	
	
UPDATE dbo.AbuseReports
SET ReportedUserID = @ReportedUserID
WHERE AbuseReportID = @AbuseReportID;



/************ PARTE 2. BANEAR EL USUARIO SI ASI LO DESEA EL QUE REPORTA ************/
/*** ESTO SOLO IMPLICA QUE EL QUE REPORTA YA NO VERA NADA RELACIONADO CON EL MENCIONADO USUARIO *****/
IF (@BanUser = 1) BEGIN

	IF NOT EXISTS(SELECT 1 FROM dbo.User_BannedUsers WITH(NOLOCK) WHERE UserID = @ReportingUserID AND BannedUserID = @ReportedUserID) BEGIN
		
		INSERT INTO dbo.User_BannedUsers 
		VALUES (@ReportingUserID, @ReportedUserID, GETDATE());

	END;

	DELETE dbo.User_UsersFollowed
	WHERE UserID = @ReportingUserID
		AND UserIDFollowed = @ReportedUserID;

	IF (@@ROWCOUNT > 1) BEGIN
		EXEC dbo.Notifications_Update_Agenda_Create 
			@UserID = @ReportingUserID;
	END;

END;


	
/*
--AbuseReportID			bigint			Unchecked
--ObjectID				tinyint			Checked
--IdOfObjectBeingReported	bigint		Checked
--ReportTypeID			smallint		Checked
--ReportingUserID		bigint			Checked
ReportedUserID			bigint			Checked --TO BE FETCHED IN QUERY

--ReportDate			smalldatetime	Checked
--PostingIDForReportFollowUp	bigint	Checked
--ReportedItemTitle		nvarchar(100)	Checked
--ReportedItemQuote		nvarchar(100)	Checked
--ReportedItemMessage	nvarchar(4000)	Checked

AssignedToEmployeeID	bigint			Checked
FirstUpdate				smalldatetime	Checked
LastUpdate				smalldatetime	Checked

--Active				bit				Checked
*/


/*
	EL USUARIO QUE REPORTA EL PROBLEMA 
		EN Int64.Parse(context.Request.QueryString["token3"])

	ID DEL ELEMENTO REPORTADO
            ReportedObjectID = sContent.Substring(0, sContent.IndexOf("&token5="));
	
	TITULO DEL ELEMENTO REPORTADO
			ReportedObjectTitle = sContent.Substring(0, sContent.IndexOf("&token6="));

	MENSAJE DEL ELEMENTO REPORTADO
            ReportedObjectMessage = sContent.Substring(0, sContent.IndexOf("&token7="));
	
	ARCHIVOS CONTENIDOS EN EL OBJETO (ESTO SERIAN IMAGENES POR EL MOMENTO)
            ReportedObjectFiles = sContent.Substring(0, sContent.IndexOf("&token8="));
	
	PRECIO CITADO EN EL OBJETO (SI APLICA)
            ReportedObjectQuote = sContent.Substring(0, sContent.IndexOf("&token9="));
	
	CATEGORIA DEL REPORTE (TIPO DE VIOLACION, EJEMPLO: VIOLA COPYRIGHT, INCITA AL VANDALISMO, NO ES RELEVANTE AL COMERCIO, ETC...)
            ReportTypeID = sContent.Substring(0, sContent.IndexOf("&token10="));
	
	MENSAJE DEL USUARIO QUE REPORTA
      ReportMessage = sContent.Substring(0, sContent.IndexOf("&token11="));
	
	SI EL USUARIO QUE EMITIO EL REPORTE NO DESEA MAS VER CONTENIDO DEL USUARIO REPORTADO
            BanUser = Boolean.Parse(sContent.Substring(0, sContent.IndexOf("&token12")));
	
	SI EL OBJETO REPORTADO ES UN POSTING, O ES UN PRODUCTO O ES UNA PERSONA	
            objectTypeReported = (sContent == "1") ? EntityReported.Posting : (sContent == "2") ? EntityReported.Product : (sContent == "3") ? EntityReported.User : EntityReported.Empty;
*/



GO
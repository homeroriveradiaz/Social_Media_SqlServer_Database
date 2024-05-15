USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Location_EnterNewLocation_ByLocationString]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'SuiGenerisSearchCriteria_Add_Location', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.SuiGenerisSearchCriteria_Add_Location AS SELECT 1;');
END;
GO

/****************************************************************************

RETURNS
	@Add AS [Added] ------------------------------------------->	(1 is added, 0 is not added)
	, @NotAddedBecause AS NotAddedBecause --------------------->	(if Add is 1 then NULL. Otherwise, 1 when the proposed location does not exist, or 2 in case user already covers the location)
	, @IfAddedRemoveOthers AS IfAddedRemoveOthers ------------->	(NULL if not added.   If a location is added, then 1 to indicate other locations should be removed. Else 0, no locations to delete)
	, @Deletions AS Deletions --------------------------------->	(NULL unless there are locations to remove. If locations do exist, then <DeleteLocations><LocationID>12345</LocationID><LocationID>67890</LocationID><LocationID>34567</LocationID></DeleteLocations>)
	, @NewLocation AS NewLocation ----------------------------->	(In case Add = 1, then any location string such as 'Los Angeles, CA, US')
	, @NewUserLocationRowID AS NewUserLocationRowID; ---------->	(In case Add = 1, the id for this users new location, such as -232200)

****************************************************************************/
ALTER PROCEDURE [dbo].[SuiGenerisSearchCriteria_Add_Location](
	@UserID BIGINT
	, @NewLocationString NVARCHAR(100)
)
AS


DECLARE @BestRowID INT
	, @CountryID INT
	, @StateID INT
	, @CityID INT

	, @Add BIT = NULL
	, @NotAddedBecause BIT = NULL
	, @IfAddedRemoveOthers BIT = NULL
	, @NewLocation NVARCHAR(100) = NULL
	, @NewUserLocationRowID AS INT = NULL;

DECLARE @DeletionsTable AS TABLE (
	UserRowID INT
);



EXEC dbo.LocationSearch_Get_BestMatch_CityLevel_ByLocationString
	@Locationstring = @NewLocationString
	, @CountryID = @CountryID OUTPUT
	, @StateID = @StateID OUTPUT
	, @CityID = @CityID OUTPUT
	, @ExactLocationstring = @NewLocation OUTPUT;

/************************************************************************
Now define what should be done by using the CountryID, StateID
and CountryID and compare with what the user already has in table 
dbo.User_LocationsFollowed
************************************************************************/

/*  IS IT ALREADY COVERED?  */
IF EXISTS(
	SELECT 1
	FROM dbo.User_LocationsFollowed WITH(NOLOCK)
	WHERE UserID = @UserID
		AND CountryID = @CountryID
		AND StateID = @StateID
		AND CityID = @CityID
) BEGIN
	SET @Add = 0;
END; ELSE BEGIN
	SET @Add = 1;
END;


IF (@Add = 1) BEGIN
	
	SELECT @NewUserLocationRowID = MAX(UserRowID) + 1
	FROM dbo.User_LocationsFollowed WITH(NOLOCK)
	WHERE UserID = @UserID;

	SET @NewUserLocationRowID = ISNULL(@NewUserLocationRowID, -2147483648);

	INSERT INTO dbo.User_LocationsFollowed 
	VALUES (@UserID, @NewUserLocationRowID, @CountryID, @StateID, @CityID);

END;



SELECT (
	SELECT @Add AS [added]
		, @NewLocation AS location
		, @NewUserLocationRowID AS searchLocationId	
	FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
) AS jsonString;


GO




--DEFINICION HASTA EL 20 de JUNIO del 2020
--ALTER PROCEDURE [dbo].[SuiGenerisSearchCriteria_Add_Location](
--	@UserID BIGINT
--	, @NewLocationString NVARCHAR(100)
--)
--AS


--DECLARE @BestRowID INT
--	, @CountryID INT
--	, @StateID INT
--	, @CityID INT
--	, @CountryAbreviation AS VARCHAR(100)
--	, @Country AS VARCHAR(100)
--	, @StateAbbreviation AS VARCHAR(100)
--	, @State AS VARCHAR(100)
--	, @City AS VARCHAR(100)

--	--TO SHOW AT THE END
--	, @Add BIT = NULL
--	, @NotAddedBecause BIT = NULL
--	, @IfAddedRemoveOthers BIT = NULL
--	, @NewLocation NVARCHAR(200) = NULL
--	, @NewUserLocationRowID AS INT = NULL;

--DECLARE @DeletionsTable AS TABLE (
--	UserRowID INT
--);

--DECLARE @MatchesTable TABLE (
--	RowID INT,
--	CountryID INT,
--	StateID INT,
--	CityID INT
--);


--/***********************************************************************
--We first see how many locations match the search criteria.
--If more than one, we select the lowest ID there is.
--***********************************************************************/
--INSERT INTO @MatchesTable(RowID, CountryID, StateID, CityID)
--SELECT RowID, CountryID, StateID, CityID
--FROM dbo.UserLocationsSearch WITH(NOLOCK)
--WHERE FullCityName_State_Country LIKE @NewLocationString + '%';

--SELECT @BestRowID = MIN(RowID)
--FROM @MatchesTable;

--SELECT @CountryID = CountryID, @StateID = StateID, @CityID = CityID
--FROM @MatchesTable
--WHERE RowID = @BestRowID;

--/***********************************************************************
--If not one match exists, set not-added and not-added-reason flags
--and go straight to the end of the procedure
--***********************************************************************/
--IF (@BestRowID IS NULL) BEGIN

--	SELECT @Add = 0
--		, @NotAddedBecause = 1;

--	GOTO EndOfProcedure;
--END;


--/***********************************************************************
--Fetch Country name, state name and city name.
--Assemble name appropriately
--***********************************************************************/
--SELECT @Country = Country, @CountryAbreviation = CountryAbbreviation
--FROM dbo.Location_Countries WITH(NOLOCK)
--WHERE CountryID = @CountryID;

--SELECT @StateAbbreviation = StateAbbreviation, @State = [State]
--FROM dbo.Location_States WITH(NOLOCK)
--WHERE StateID = @StateID
--	AND CountryID = @CountryID;

--SELECT @City = City
--FROM dbo.Location_Cities WITH(NOLOCK)
--WHERE StateID = @StateID
--	AND CityID = @CityID;

--IF (@StateID = -1 AND @CityID = -1) BEGIN
--	SET @NewLocation = 'all ' + @Country;
--END; ELSE IF (@CityID = - 1) BEGIN
--	SET @NewLocation = 'all cities in ' + @StateAbbreviation + ', ' + @CountryAbreviation;
--END; ELSE BEGIN
--	SET @NewLocation = @City + ', ' + @StateAbbreviation + ', ' + @CountryAbreviation;
--END;


--/************************************************************************
--Now define what should be done by using the CountryID, StateID
--and CountryID and compare with what the user already has in table 
--dbo.User_LocationsFollowed
--************************************************************************/

--/*   IS THERE ALREADY AN EQUAL ROW?    */
--IF EXISTS(SELECT 1 FROM dbo.User_LocationsFollowed WITH(NOLOCK) WHERE UserID = @UserID AND CountryID = @CountryID AND StateID = @StateID AND CityID = @CityID) BEGIN
--/*    YES, THE ROW ALREADY EXISTS */
	
--	SELECT @Add = 0
--		, @NotAddedBecause = 2;

--END; ELSE BEGIN

--	/*    IS THERE A ROW FOR THAT COUNTRY?    */
--	IF EXISTS(SELECT 1 FROM dbo.User_LocationsFollowed WITH(NOLOCK) WHERE UserID = @UserID AND CountryID = @CountryID) BEGIN
--		/*    YES, THERE IS A ROW WITH THAT COUNTRY    */
	
--		/*    IS SUCH ROW WITH THE SAME COUNTRY AND IT COVERS ALL STATES (StateID = -1)?    */
--		IF EXISTS(SELECT 1 FROM dbo.User_LocationsFollowed WITH(NOLOCK) WHERE UserID = @UserID AND CountryID = @CountryID AND StateID = -1) BEGIN
--			/*    THEN, RETURN AN ERROR, CAUSE IT'S ALREADY COVERED!    */

--			SELECT @Add = 0
--				, @NotAddedBecause = 2;

--		END; ELSE BEGIN
--			/*   NO, THERE IS NO 'ALL STATES'   */

--			/*    IS THE ROW I'M INSERTING ONE THAT COVERS ALL STATES FOR THE COUNTRY?  StateID -1  */
--			IF (@StateID = -1) BEGIN
--				/*    THEN THROW AWAY THE ROWS FOR THAT COUNTRY AND INSERT MY ROW    */
				
--				SET @IfAddedRemoveOthers = 0;

--				DELETE dbo.User_LocationsFollowed 
--					OUTPUT deleted.UserRowID INTO @DeletionsTable(UserRowID)
--				WHERE UserID = @UserID 
--					AND CountryID = @CountryID;

--				IF (@@ROWCOUNT > 0) BEGIN
--					SET @IfAddedRemoveOthers = 1;
--				END;

--				SET @Add = 1;

				
--			END; ELSE BEGIN
				
--				/*    IS THERE A ROW FOR THE SAME STATE WHERE IT COVERS ALL CITIES?    */
--				IF EXISTS(SELECT * FROM dbo.User_LocationsFollowed WITH(NOLOCK) WHERE UserID = @UserID AND CountryID = @CountryID AND StateID = @StateID AND CityID = -1) BEGIN

--					SELECT @Add = 0
--						, @NotAddedBecause = 2;
				
--				END; ELSE BEGIN
				
--					/*    AM I INSERTING A ROW FOR SAME COUNTRY-STATE AND ALL CITIES -1 ?    */
--					IF (@CityID = -1) BEGIN
--						/*    THEN DELETE THE ROWS FOR THE SAME STATE AND INSERT MY ROW    */
						
--						SET @IfAddedRemoveOthers = 0;

--						DELETE dbo.User_LocationsFollowed
--							OUTPUT deleted.UserRowID INTO @DeletionsTable(UserRowID)
--						WHERE UserID = @UserID
--							AND CountryID = @CountryID
--							AND StateID = @StateID;


--						IF (@@ROWCOUNT > 0) BEGIN
--							SET @IfAddedRemoveOthers = 1;
--						END;
						
--						SET @Add = 1;


--					END; ELSE BEGIN
--						/*    THEN INSERT MY ROW    */

--						SELECT @Add = 1
--							, @IfAddedRemoveOthers = 0;

--					END;
--				END;
--			END;
--		END;
--	END; ELSE BEGIN
--	/*     NO ROW EXISTS FOR SUCH COUNTRY, PROCEED TO INSERT    */

--		SELECT @Add = 1
--			, @IfAddedRemoveOthers = 0;

--	END;
--END;


--IF (@Add = 1) BEGIN

--	SELECT @NewUserLocationRowID = MAX(UserRowID) + 1
--	FROM dbo.User_LocationsFollowed WITH(NOLOCK)
--	WHERE UserID = @UserID;

--	SET @NewUserLocationRowID = ISNULL(@NewUserLocationRowID, -2147483648);


--	INSERT INTO dbo.User_LocationsFollowed 
--	VALUES (@UserID, @NewUserLocationRowID, @CountryID, @StateID, @CityID);

--END;


--	EndOfProcedure:


--SELECT (
--	SELECT @Add AS [added]
--		, @NotAddedBecause AS notAddedBecause
--		, @IfAddedRemoveOthers AS ifAddedRemoveOthers
--		, (ISNULL((
--			SELECT UserRowID AS searchLocationId 
--			FROM @DeletionsTable 
--			FOR JSON AUTO
--		), '[]')) AS deletions
--		, @NewLocation AS location
--		, @NewUserLocationRowID AS searchLocationId	
--	FOR JSON PATH, INCLUDE_NULL_VALUES, WITHOUT_ARRAY_WRAPPER
--) AS jsonString;

--GO
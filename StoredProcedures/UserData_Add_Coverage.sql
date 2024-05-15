USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Profile_Add_Coverage]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO


IF OBJECT_ID(N'UserData_Add_Coverage', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.UserData_Add_Coverage AS SELECT 1;');
END;
GO


ALTER PROCEDURE [dbo].[UserData_Add_Coverage](
	@UserID BIGINT
	, @Locationstring NVARCHAR(100)
)
AS

/*
	Result
	--------
	covered/overtakes/add/notfound
*/

DECLARE @CountryID INT
	, @StateID INT
	, @CityID INT
	, @ExactLocationstring NVARCHAR(100)
	, @NewCoverageID BIGINT;

EXEC dbo.LocationSearch_Get_BestMatch_CityLevel_ByLocationString
	@Locationstring = @Locationstring
	, @CountryID = @CountryID OUTPUT
	, @StateID = @StateID OUTPUT
	, @CityID = @CityID OUTPUT
	, @ExactLocationstring = @ExactLocationstring OUTPUT;

DECLARE @Result VARCHAR(20);


IF (@CountryID IS NULL) BEGIN

	SET @Result = 'notfound';

	SELECT (
		SELECT @Result AS result
			, @CountryID AS countryId
			, @StateID AS stateId
			, @CityID AS cityId
			, @ExactLocationstring AS exactLocationString
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
	) AS jsonString;


	RETURN;

END;



DECLARE @Coverage AS TABLE(
	CoverageID BIGINT NOT NULL
	, CountryID INT NOT NULL
	, StateID INT NOT NULL
	, CityID INT NOT NULL
	, ToDo CHAR(10) NULL
);


INSERT INTO @Coverage(CoverageID, CountryID, StateID, CityID)
SELECT CoverageID, CountryID, StateID, CityID
FROM dbo.Coverage WITH(NOLOCK)
WHERE UserID = @UserID
	AND Active = 1;




--see if it already exists
IF EXISTS(SELECT 1 FROM @Coverage WHERE CountryID = @CountryID AND StateID = @StateID AND CityID = @CityID) BEGIN
	
	SET @Result = 'covered';

END; ELSE BEGIN

--now see if its covered by a wider scope such as state-wide or country-wide	
	IF EXISTS(SELECT 1 FROM @Coverage WHERE CountryID = @CountryID AND StateID = -1 AND CityID = -1) 
		OR EXISTS(SELECT 1 FROM @Coverage WHERE CountryID = @CountryID AND StateID = @StateID AND CityID = -1) BEGIN

		SET @Result = 'covered';

	END; ELSE IF (@StateID = -1) BEGIN

--now see if this one would cover a wider scope, first at country level
		IF EXISTS(SELECT 1 FROM @Coverage WHERE CountryID = @CountryID) BEGIN
			
			UPDATE dbo.Coverage
			SET Active = 0
			WHERE UserID = @UserID
				AND CountryID = @CountryID;
			
			INSERT INTO dbo.Coverage(UserID, DateCreated, CountryID, StateID, CityID, Active)
			VALUES (@UserID, GETDATE(), @CountryID, @StateID, @CityID, 1);

			SET @NewCoverageID = SCOPE_IDENTITY();
			
			SET @Result = 'overtakes';

		END;
--then at state level
	END; ELSE IF (@CityID = -1) BEGIN
		
		IF EXISTS(SELECT 1 FROM @Coverage WHERE CountryID = @CountryID AND StateID = @StateID) BEGIN
			
			UPDATE dbo.Coverage
			SET Active = 0
			WHERE UserID = @UserID
				AND CountryID = @CountryID
				AND StateID = @StateID;
			
			INSERT INTO dbo.Coverage(UserID, DateCreated, CountryID, StateID, CityID, Active)
			VALUES (@UserID, GETDATE(), @CountryID, @StateID, @CityID, 1);

			SET @NewCoverageID = SCOPE_IDENTITY();
			
			SET @Result = 'overtakes';

		END;
		
	END; ELSE BEGIN
		--no impediments to enter as-is
			INSERT INTO dbo.Coverage(UserID, DateCreated, CountryID, StateID, CityID, Active)
			VALUES (@UserID, GETDATE(), @CountryID, @StateID, @CityID, 1);

			SET @NewCoverageID = SCOPE_IDENTITY();
			
			SET @Result = 'add';

	END;


END;



SELECT (
	SELECT @Result AS result,
		@CountryID AS countryId,
		@StateID AS stateId,
		@CityID AS cityId,
		ISNULL(@ExactLocationstring, N'') AS exactLocationString,
		CAST(@NewCoverageID AS NVARCHAR) AS coverageId
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER, INCLUDE_NULL_VALUES
) AS jsonString;


GO


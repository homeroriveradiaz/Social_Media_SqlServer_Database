USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[User_PostMessageResponse]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'dbo.Postings_Add_LocationsToPosting', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.Postings_Add_LocationsToPosting AS SELECT 1;');
END;
GO
/*********************************************************************************
THIS SPROC ASSIGNS LOCATIONS TO A POSTING.
*********************************************************************************/
ALTER PROC dbo.Postings_Add_LocationsToPosting(
	@PostingID BIGINT
	, @LocationsString NVARCHAR(4000)
) AS



DECLARE @TempLocations TABLE(
	CountryID INT
	, StateID INT
	, CityID INT
);


/****************************************************************
	PART I.
	DISMISS FALSE LOCATIONS

****************************************************************/
INSERT INTO @TempLocations(CountryID, StateID, CityID)
SELECT DISTINCT BLU.CountryID, BLU.StateID, BLU.CityID
FROM dbo.fn_break_location_in_underscores(@LocationsString) AS BLU
INNER JOIN dbo.UserLocationsSearch AS ULS WITH(NOLOCK) ON BLU.CountryID = ULS.CountryID 
	AND BLU.StateID = ULS.StateID 
	AND BLU.CityID = ULS.CityID;



/****************************************************************
	PART II.
	DISMISS LOCATIONS IF ALREADY COVERED BY A -1 AT THE STATE
	OR CITY LEVEL

****************************************************************/
DELETE @TempLocations
FROM @TempLocations AS T1
WHERE T1.StateID <> -1
	AND EXISTS(
		SELECT 1
		FROM @TempLocations AS T2
		WHERE T2.CountryID = T1.CountryID
			AND T2.StateID = -1
	);


DELETE @TempLocations
FROM @TempLocations AS T1
WHERE T1.StateID <> -1
	AND T1.CityID <> -1
	AND EXISTS(
		SELECT 1
		FROM @TempLocations AS T2
		WHERE T2.CountryID = T1.CountryID
			AND T2.StateID = T1.StateId
			AND T2.CityID = -1
	);



/****************************************************************
	PART III.
	INSERT TO POSTINGS_LOCATIONS

****************************************************************/
INSERT INTO dbo.Postings_Locations(PostingID, CountryID, StateID, CityID, Active)
SELECT @PostingID, CountryID, StateID, CityID, 1
FROM @TempLocations;




GO


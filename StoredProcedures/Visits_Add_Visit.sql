
CREATE OR ALTER PROC dbo.Visits_Add_Visit(
	@VisitingSectionID SMALLINT
	, @EntityID NVARCHAR(200) = NULL -- MUST BE POPULATED WHEN VisitingSectionID = 1 (User Profile), 2 (Article), 3 (), , 5 (Session Search page), 6 (Session Profile page), 7 (Single posting - Profile). MUST BE NULL when 4 (Main Page)
	, @IP BIGINT = NULL --MUST BE POPULATED WHEN VisitingSectionID = 3 (Hashtag search list).     WARNING!! WARNING!! WARNING!! This is prepared only for IPv4 and will require IPv6 soon
) AS 

/* importante, aún faltan conteos para (3, 'Hashtag search list') */
DECLARE @ID BIGINT, @CityId INT;

IF (@VisitingSectionID = 1) BEGIN --when 1 (User Profile) this is expected to be a UserPublickKey

	SELECT @ID = UserID
	FROM [dbo].[UsersPublicKey]
	WHERE [ShortenedNameFull] = @EntityID;
	
	IF @ID IS NULL BEGIN
		RAISERROR(N'Invalid parameter value', 16, 1);
		RETURN;
	END;
END; ELSE IF (@VisitingSectionID = 3) BEGIN
	
	IF (@IP IS NOT NULL AND @EntityID IS NOT NULL) BEGIN
		
		EXEC dbo.LocationSearch_Get_LocationBasedOnIP
			@IpAddress = @IP
			, @IPAddressVersion = 'v4' --WARNING!!! WARNING!!! WARNING!!! this is hardcoded to v4!! When we adapt to IPv6 then we 
			, @CityID = @CityId OUTPUT;
		
		IF @CityId IS NULL
			SET @CityId = -1;
		
		SELECT TOP (1) @ID = ISNULL(ChildCategoryId, -1) --Just validating the category
		FROM dbo.AdsChildCategories
		WHERE ChildCategoryId = CAST(@EntityID AS int);

		
	END; ELSE BEGIN
		RAISERROR(N'Invalid parameter value', 16, 1);
		RETURN;
	END;
	
END; ELSE IF (@VisitingSectionID = 4) BEGIN --Main. when 4, make sure this is NULL
	IF @EntityID IS NOT NULL BEGIN
		RAISERROR(N'Invalid parameter value', 16, 1);
		RETURN;
	END;
END;
ELSE IF (@VisitingSectionID IN (2, 5, 6, 7)) BEGIN --when 2, 5, 6 or 7 then make sure this is bigint. Try parsing
	SET @ID = TRY_CAST(@EntityID AS BIGINT);	
	IF @ID IS NULL BEGIN
		RAISERROR(N'Invalid parameter value', 16, 1);
		RETURN;
	END;
END; 
ELSE BEGIN
	RAISERROR(N'Invalid parameter value', 16, 1);
	RETURN;
END;


IF (@VisitingSectionID IN (1, 2, 5, 6, 7)) BEGIN

	WITH CurrDateTimeEvent AS (
		SELECT @VisitingSectionID AS VisitingSectionID, 
			@ID AS EntityID,
			CAST(GETUTCDATE() AS date) AS VisitDate,
			DATEPART(HOUR, GETUTCDATE()) AS VisitHour
	)
	MERGE INTO dbo.Visits AS T
	USING CurrDateTimeEvent AS S
	ON T.VisitingSectionID = S.VisitingSectionID
		AND T.EntityID = S.EntityID
		AND T.VisitDate = S.VisitDate
		AND T.VisitHour = S.VisitHour
	WHEN MATCHED THEN 
	UPDATE
		SET AmountOfVisits = AmountOfVisits + 1
	WHEN NOT MATCHED THEN 
		INSERT(VisitDate, VisitHour, VisitingSectionID, EntityID, AmountOfVisits)
		VALUES(S.VisitDate, S.VisitHour, S.VisitingSectionID, S.EntityID, 1);

	IF (@VisitingSectionID IN (5, 6)) BEGIN
		UPDATE dbo.Users
		SET LastVisitingSectionID = @VisitingSectionID
		WHERE UserID = @ID;
	END;

END; ELSE IF (@VisitingSectionID = 4) BEGIN

	WITH CurrDateTimeEvent AS (
		SELECT @VisitingSectionID AS VisitingSectionID, 
			CAST(GETUTCDATE() AS date) AS VisitDate,
			DATEPART(HOUR, GETUTCDATE()) AS VisitHour
	)
	MERGE INTO dbo.Visits AS T
	USING CurrDateTimeEvent AS S
	ON T.VisitingSectionID = S.VisitingSectionID
		AND T.VisitDate = S.VisitDate
		AND T.VisitHour = S.VisitHour
	WHEN MATCHED THEN 
	UPDATE
		SET AmountOfVisits = AmountOfVisits + 1
	WHEN NOT MATCHED THEN 
		INSERT(VisitDate, VisitHour, VisitingSectionID, AmountOfVisits)
		VALUES(S.VisitDate, S.VisitHour, S.VisitingSectionID, 1);

END; ELSE IF (@VisitingSectionID = 3) BEGIN

	WITH CurrDateTimeEvent AS (
		SELECT @VisitingSectionID AS VisitingSectionID, 
			CAST(GETUTCDATE() AS date) AS VisitDate,
			DATEPART(HOUR, GETUTCDATE()) AS VisitHour,
			@Id AS EntityID,
			@CityId AS CityID
	)
	MERGE INTO dbo.Visits AS T
	USING CurrDateTimeEvent AS S
	ON T.VisitingSectionID = S.VisitingSectionID
		AND T.VisitDate = S.VisitDate
		AND T.VisitHour = S.VisitHour
		AND T.EntityID = S.EntityID
		AND T.CityID = S.CityID
	WHEN MATCHED THEN 
	UPDATE
		SET AmountOfVisits = AmountOfVisits + 1
	WHEN NOT MATCHED THEN 
		INSERT(VisitDate, VisitHour, VisitingSectionID, AmountOfVisits, EntityID, CityID)
		VALUES(S.VisitDate, S.VisitHour, S.VisitingSectionID, 1, S.EntityID, S.CityID);
END;


GO


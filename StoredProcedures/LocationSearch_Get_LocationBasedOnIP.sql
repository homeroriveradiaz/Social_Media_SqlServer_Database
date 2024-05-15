USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Subscriber_AddUserData]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID(N'dbo.LocationSearch_Get_LocationBasedOnIP', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.LocationSearch_Get_LocationBasedOnIP AS SELECT 1;');
END;
GO


ALTER PROC dbo.LocationSearch_Get_LocationBasedOnIP(
	@IpAddress DECIMAL(38, 0)
	, @IPAddressVersion varchar(10) --v4 or v6
	, @CountryID INT = NULL OUTPUT
	, @StateID INT = NULL OUTPUT
	, @CityID INT OUTPUT
) AS


DECLARE @IPVersion TINYINT
	, @ClosestBelow DECIMAL(38, 0)
	, @ClosestAbove DECIMAL(38, 0)
	, @IPAddressRangeGeographyID BIGINT;


IF (@IPAddressVersion = 'v4') BEGIN
	SET @IPVersion = 1;
END; ELSE IF (@IPAddressVersion = 'v6') BEGIN
	SET @IPVersion = 2;
END; ELSE BEGIN
	THROW 51000, 'Invalid ip version. Only v4 and v6 are valid values for ip address version.', 1;
END;



--in case there is a gap in the ip address ranges just pick the closest range available
SELECT @ClosestBelow = MAX(ToIP)
FROM dbo.IPAddress_VS_Location WITH(NOLOCK)
WHERE ToIP < @IpAddress
	AND IPAddressVersionID = @IPVersion;

SELECT @ClosestAbove = MIN(FromIP)
FROM dbo.IPAddress_VS_Location WITH(NOLOCK)
WHERE FromIP > @IpAddress
	AND IPAddressVersionID = @IPVersion;

--check if both are still null, if not, fail. Shouldnt fail as a boundary to wither side should always exist.
IF NOT(@ClosestBelow IS NULL AND @ClosestAbove IS NULL) BEGIN
		
	IF (@ClosestBelow IS NULL) BEGIN

		SELECT @IPAddressRangeGeographyID = MIN(IPAddressRangeGeographyID)
		FROM dbo.IPAddress_VS_Location WITH(NOLOCK)
		WHERE @ClosestAbove BETWEEN FromIP AND ToIP
			AND IPAddressVersionID = @IPVersion;

	END; ELSE IF (@ClosestAbove IS NULL) BEGIN

		SELECT @IPAddressRangeGeographyID = MIN(IPAddressRangeGeographyID)
		FROM dbo.IPAddress_VS_Location WITH(NOLOCK)
		WHERE @ClosestBelow BETWEEN FromIP AND ToIP
			AND IPAddressVersionID = @IPVersion;

	END; ELSE BEGIN

		IF (ABS(@ClosestAbove - @IpAddress) <= ABS(@ClosestBelow - @IpAddress)) BEGIN
			SELECT @IPAddressRangeGeographyID = MIN(IPAddressRangeGeographyID)
			FROM dbo.IPAddress_VS_Location WITH(NOLOCK)
			WHERE @ClosestAbove BETWEEN FromIP AND ToIP
				AND IPAddressVersionID = @IPVersion;

		END; ELSE IF (ABS(@ClosestAbove - @IpAddress) > ABS(@ClosestBelow - @IpAddress)) BEGIN

			SELECT @IPAddressRangeGeographyID = MIN(IPAddressRangeGeographyID)
			FROM dbo.IPAddress_VS_Location WITH(NOLOCK)
			WHERE @ClosestBelow BETWEEN FromIP AND ToIP
				AND IPAddressVersionID = @IPVersion;

		END;
	END;
END; ELSE BEGIN
	
	RAISERROR('could not find ip address range', 16, 1);

END;

--Set values to output params.
SELECT @CountryID = CountryID, @StateID = StateID, @CityId = CityID
FROM dbo.IPAddress_VS_Location WITH(NOLOCK)
WHERE IPAddressRangeGeographyID = @IPAddressRangeGeographyID;


RETURN;

GO




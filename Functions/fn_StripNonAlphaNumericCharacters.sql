USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[IPAddressVersions]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

CREATE FUNCTION [dbo].[fn_StripNonAlphaNumericCharacters](
    @String NVARCHAR(100)
)
RETURNS NVARCHAR(100)
AS
BEGIN
	
    DECLARE @MatchExpression NVARCHAR(100) =  '%[^a-z0-9]%';

    WHILE PATINDEX(@MatchExpression, @String) > 0
        SET @String = STUFF(@String, PATINDEX(@MatchExpression, @String), 1, '');

    RETURN @String;

END;
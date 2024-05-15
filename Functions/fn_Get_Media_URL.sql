-- =========================================================
-- Create Scalar Function template for Windows Azure SQL Database
-- =========================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- returns the default media URL domain and folder for all saved images
-- =============================================
CREATE FUNCTION dbo.fn_Get_Media_URL()
RETURNS VARCHAR(200)
AS
BEGIN

	RETURN 'https://usctrlstrg0001.blob.core.windows.net/prod-mx/';
	

END
GO


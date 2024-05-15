USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[DevicesVersionServices]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE TABLE dbo.Coverage(
	CoverageID BIGINT NOT NULL IDENTITY(-9223372036854775808, 1)
	, UserID BIGINT NOT NULL
	, DateCreated SMALLDATETIME NOT NULL
	, CountryID INT NOT NULL
	, StateID INT NOT NULL
	, CityID INT NOT NULL
	, Active BIT NOT NULL
);
GO

ALTER TABLE dbo.Coverage
ADD CONSTRAINT PK_Coverage_ConverageID PRIMARY KEY (CoverageID);
GO

ALTER TABLE dbo.Coverage
ADD CONSTRAINT FK_Coverage_UserID FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID);
GO


CREATE NONCLUSTERED INDEX NCIX_Coverage_UserID
ON dbo.Coverage(UserID ASC);
GO

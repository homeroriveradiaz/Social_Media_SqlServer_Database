USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[Languages]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE dbo.Websites(
	WebsiteID BIGINT IDENTITY(-9223372036854775808, 1) NOT NULL
	, UserID BIGINT NOT NULL
	, DateCreated SMALLDATETIME NOT NULL
	, Website NVARCHAR(100) NOT NULL
	, Active BIT NOT NULL
);
GO

ALTER TABLE dbo.Websites
ADD CONSTRAINT PK_Websites_WebsiteID PRIMARY KEY (WebsiteID);
GO

ALTER TABLE dbo.Websites
ADD CONSTRAINT FK_Websites_UserID FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID);
GO

CREATE INDEX NCIX_Websites_UserID
ON dbo.Websites(UserID ASC);
GO



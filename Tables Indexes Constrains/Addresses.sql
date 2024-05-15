USE ReadWrite_Prod;
GO
/****** Object:  Table [dbo].[Currencies]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE dbo.Addresses(
	AddressID BIGINT IDENTITY(-9223372036854775808, 1) NOT NULL,
	UserID BIGINT NOT NULL,
	DateCreated SMALLDATETIME NOT NULL,
	[Address] NVARCHAR(100) NOT NULL,
	Active BIT NOT NULL
);
GO

ALTER TABLE dbo.Addresses
ADD CONSTRAINT PK_Addresses_AddressID PRIMARY KEY (AddressID);
GO


CREATE INDEX NCIX_Addresses_UserID 
ON dbo.Addresses(UserID ASC);
GO


ALTER TABLE dbo.Addresses
ADD CONSTRAINT FK_Addresses_UserID FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID);
GO




USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[Users]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Products](
	ProductID BIGINT IDENTITY(-9223372036854775808,1) NOT NULL,
	UserID BIGINT NOT NULL,
	DateCreated SMALLDATETIME NULL,
	ProductName NVARCHAR(50) NULL,
	ProductDescription NVARCHAR(500) NULL,
	Price MONEY NULL,
	PriceCurrencyID INT  NULL,
	MainImage VARCHAR(200),
	Hierarchy SMALLINT,
	AttachedImagesCount smallint NULL DEFAULT(0),
	Active BIT NULL
) ON [PRIMARY]

GO

ALTER TABLE dbo.Products 
ADD CONSTRAINT PK_Products_ProductID PRIMARY KEY(ProductID);
GO

ALTER TABLE dbo.Products
ADD CONSTRAINT FK_Products_UserID FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID);
GO

CREATE NONCLUSTERED INDEX NCIX_Products_UserID ON dbo.Products(UserID ASC);
GO



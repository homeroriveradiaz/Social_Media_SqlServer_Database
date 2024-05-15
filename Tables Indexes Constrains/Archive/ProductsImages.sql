USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[Postings]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE dbo.ProductsImages(
	ProductImageID BIGINT IDENTITY(-9223372036854775808, 1) NOT NULL,
	ProductID BIGINT NOT NULL,
	ImageID BIGINT NOT NULL
);
GO

ALTER TABLE dbo.ProductsImages 
ADD CONSTRAINT PK_ProductsImages_ProductImageID PRIMARY KEY (ProductImageID);
GO

ALTER TABLE dbo.ProductsImages
ADD CONSTRAINT FK_ProductsImages_ProductID FOREIGN KEY (ProductID) REFERENCES dbo.Products(ProductID);
GO

--ALTER TABLE dbo.ProductsImages
--ADD CONTRAINT FK_ProductsImages_ImageID FOREIGN KEY (ImageID) REFERENCES dbo.Images(ImageID);
--GO

CREATE NONCLUSTERED INDEX NCIX_ProductsImages_ProductID 
ON dbo.ProductsImages(ProductID);
GO








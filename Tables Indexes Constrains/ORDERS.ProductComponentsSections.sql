CREATE TABLE ORDERS.ProductComponentsSections(
	ProductComponentSectionID BIGINT IDENTITY(-9223372036854775808, 1),
	ProductComponentSectionName NVARCHAR(100),
	ProductID BIGINT,
	IsNoSection BIT NOT NULL, --If the product has no other sections, then display no section
	AmountOfEligibleComponents INT,
	ProductComponentSectionOrder INT
);
GO
ALTER TABLE ORDERS.ProductComponentsSections ADD CONSTRAINT PK_ORDERS_ProductComponentsSections_ProductComponentSectionID PRIMARY KEY (ProductComponentSectionID);
GO
ALTER TABLE ORDERS.ProductComponentsSections ADD CONSTRAINT FK_ORDERS_ProductComponentsSections_ProductID FOREIGN KEY (ProductID) REFERENCES ORDERS.Products(ProductID);
GO
CREATE TABLE ORDERS.ProductComponents(
	ProductComponentID BIGINT IDENTITY(-9223372036854775808, 1),
	ProductComponentName NVARCHAR(100) NULL,
	ProductComponentsSectionID BIGINT NULL,
	ProductComponentOrder INT NOT NULL
);
GO
ALTER TABLE ORDERS.ProductComponents ADD CONSTRAINT PK_ORDERS_ProductComponents_ProductComponentID PRIMARY KEY (ProductComponentID);
GO
ALTER TABLE ORDERS.ProductComponents ADD CONSTRAINT FK_ORDERS_ProductComponents_ProductComponentsSectionID FOREIGN KEY (ProductComponentsSectionID) REFERENCES ORDERS.ProductComponentsSections(ProductComponentsSectionID);
GO
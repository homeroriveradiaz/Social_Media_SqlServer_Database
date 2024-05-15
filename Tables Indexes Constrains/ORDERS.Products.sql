CREATE TABLE ORDERS.Products(
	ProductID BIGINT IDENTITY(-9223372036854775808, 1),
	ProductName NVARCHAR(100),
	ProductDescription NVARCHAR(255),
	MenuSectionID BIGINT,
	ProductOrderInMenuSection INT,
	Price MONEY,
	HasComponents BIT
);
GO
ALTER TABLE ORDERS.Products ADD CONSTRAINT PK_ORDERS_Products_ProductID PRIMARY KEY (ProductID);
GO
ALTER TABLE ORDERS.Products ADD CONSTRAINT FK_ORDERS_Products_MenuSectionID FOREIGN KEY (MenuSectionID) REFERENCES ORDERS.MenuSection(MenuSectionID);
GO
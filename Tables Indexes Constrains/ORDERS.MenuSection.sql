CREATE TABLE ORDERS.MenuSection(
	MenuSectionID BIGINT IDENTITY(-9223372036854775808, 1)
	, MenusectionName NVARCHAR(100)
	, MenuID BIGINT
	, IsNoSection BIT NOT NULL --If the menu has no other sections, then display no section, but a row must exist anyways.
	, MenuSectionOrder INT NOT NULL
	, Active BIT NOT NULL DEFAULT(1)
);
ALTER TABLE ORDERS.MenuSection ADD CONSTRAINT PK_ORDERS_MenuSection_MenuSectionID PRIMARY KEY (MenuSectionID);
GO
ALTER TABLE ORDERS.MenuSection ADD CONSTRAINT FK_ORDERS_MenuSection_MenuID FOREIGN KEY (MenuID) REFERENCES ORDERS.Menus(MenuID);
GO 
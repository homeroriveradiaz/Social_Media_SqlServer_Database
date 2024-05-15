/* All times are in UTC. The timezone of the Menu is the one used */
CREATE TABLE ORDERS.MenuOpenHours(
	MenuOpenHoursID BIGINT IDENTITY(-9223372036854775808, 1)
	, MenuID BIGINT NOT NULL
	, [Weekday] INT NOT NULL
	, FromTime TIME NOT NULL
	, ToTime TIME NOT NULL
);
ALTER TABLE ORDERS.MenuOpenHours ADD CONSTRAINT PK_ORDERS_MenuOpenHours_MenuOpenHoursID PRIMARY KEY (MenuOpenHoursID);
GO
ALTER TABLE ORDERS.MenuOpenHours ADD CONSTRAINT FK_ORDERS_MenuOpenHours_MenuID FOREIGN KEY(MenuID) REFERENCES ORDERS.Menus(MenuID);
GO
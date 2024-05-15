USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[HashtagsPostings]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE TABLE dbo.PhoneNumbers(
	PhoneNumberID BIGINT IDENTITY(-9223372036854775808, 1) NOT NULL
	, UserID BIGINT NOT NULL
	, DateCreated SMALLDATETIME NOT NULL
	, PhoneNumber NVARCHAR(20) NOT NULL
	, Active BIT NOT NULL
);
GO


ALTER TABLE dbo.PhoneNumbers
ADD CONSTRAINT PK_PhoneNumbers_PhoneNumberID PRIMARY KEY (PhoneNumberID);
GO

ALTER TABLE dbo.PhoneNumbers
ADD CONSTRAINT FK_PhoneNumbers_UserID FOREIGN KEY (UserID) REFERENCES dbo.Users(UserID);
GO

CREATE NONCLUSTERED INDEX NCIX_PhoneNumbers_UserID
ON dbo.PhoneNumbers(UserID);
GO




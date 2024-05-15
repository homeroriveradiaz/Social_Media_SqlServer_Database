USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[Users]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserID] [bigint] IDENTITY(-9223372036854775808,1) NOT NULL,
	[Username] [nvarchar](100) NOT NULL,
	[Password] [nvarchar](100) NOT NULL,
	[LastVisit] [smalldatetime] NULL,
	[DateCreated] [smalldatetime] NULL,
	[Name] [nvarchar](100) NULL,
	[Slogan] [nvarchar](100) NULL,
	[BusinessDescription] [nvarchar](500) NULL,
	[AvatarImageURL] VARCHAR(100) NULL,
	[BackgroundImageURL] VARCHAR(100) NULL,
	[BaseCountryID] INT NULL,
	[BaseStateID] INT NULL,
	[BaseCityID] INT NULL,
	[DateOfBirth] [smalldatetime] NULL,
	[Gender] [tinyint] NULL,
	[SecurityQuestion] [nvarchar](100) NULL,
	[SecurityAnswer] [nvarchar](100) NULL,
	[ContactEmail] [nvarchar](100) NULL,
	[SendEmailWhenTheyReplyToMyReplies] BIT NULL,
	[SendEmailWhenTheyReplyToMyPostings] BIT NULL,
	[SendEmailWithNewsletter] BIT NULL,
	[DefaultCurrencyId] [int] NULL,
	[DefaultToShowQuote] [bit] NULL,
	[DefaultLanguageID] [int] NULL,
	[Censored] [bit] NULL,
	[CensoredOn] [smalldatetime] NULL,
	[Active] [bit] NULL,
	[LastVisitingSectionID] [smallint] NULL
) ON [PRIMARY]

GO
/****** Object:  Index [IX_Users_UserID]    Script Date: 27/09/2017 11:53:23 p. m. ******/
ALTER TABLE [dbo].[Users]
ADD CONSTRAINT PK_Users_UserID PRIMARY KEY (UserID);
GO



GO
/****** Object:  Index [IX_Users_Username]    Script Date: 27/09/2017 11:53:23 p. m. ******/
CREATE NONCLUSTERED INDEX [IX_Users_Username] ON [dbo].[Users]
(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO





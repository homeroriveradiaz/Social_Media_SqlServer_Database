USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[Location_States]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Location_States](
	[StateID] [int] IDENTITY(1, 1) PRIMARY KEY,
	[CountryID] [int] NULL,
	[State] [nvarchar](100) NULL,
	[StateAbbreviation] [varchar](10) NULL,
	[StateAbbreviationApplicable] [bit] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[Location_States] ADD CONSTRAINT FK_LocationStates_LocationCountries 
FOREIGN KEY ([CountryID]) REFERENCES dbo.Location_Countries(CountryID);

GO
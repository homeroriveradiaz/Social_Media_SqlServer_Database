USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[Postings]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Postings](
	[PostingID] [bigint] IDENTITY(-9223372036854775808,1) NOT NULL,
	[PostingTypeID] [tinyint] NULL,
	[PostedByUserID] [bigint] NULL,
	[PostDateTime] [smalldatetime] NULL,
	[PostingTitle] [nvarchar](100) NULL,
	[PostingMessage] [nvarchar](4000) NULL,
	[FromIPAddress] [bigint] NULL,
	[Price] [money] NULL,
	[Censored] [bit] NULL,
	[AttachedImagesCount] [smallint] NULL DEFAULT(0),
	[CensoredOn] [smalldatetime] NULL,
	[Active] [bit] NULL,
	[PriceCurrencyID] [int] NULL
) ON [PRIMARY]

GO

ALTER TABLE dbo.Postings
ADD CONSTRAINT PK_Postings_PostingID PRIMARY KEY (PostingID);
GO

CREATE NONCLUSTERED INDEX NCIX_Postings_PostedByUserID 
ON dbo.Postings(PostedByUserID);
GO




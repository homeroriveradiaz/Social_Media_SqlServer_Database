USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[IPAddressVersions]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

CREATE TABLE dbo.PostingsSearchWordsList(
	PostingID BIGINT NOT NULL
	, SearchWordID BIGINT NOT NULL
);

CREATE INDEX IX_PostingsSearchWordsList_PostingID ON dbo.PostingsSearchWordsList(SearchWordID ASC);

GO
SET ANSI_PADDING OFF
GO
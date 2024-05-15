USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[SearchWords]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SearchWords](
	[SearchWordID] [bigint] IDENTITY(-9223372036854775808,1) NOT NULL,
	[Word] [nvarchar](100) NULL
) ON [PRIMARY]

GO

CREATE INDEX IX_SearchWords_Word ON [dbo].[SearchWords](Word);
GO





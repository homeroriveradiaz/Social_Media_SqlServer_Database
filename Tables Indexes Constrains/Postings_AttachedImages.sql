USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[Postings_AttachedAssets]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Postings_AttachedImages](
	[PostingAttachedImageID] [bigint] IDENTITY(-9223372036854775808, 1) NOT NULL,
	[PostingID] [bigint] NULL,
	[ImageID] [bigint] NULL
) ON [PRIMARY]
GO


ALTER TABLE dbo.Postings_AttachedImages
ADD CONSTRAINT PK_Postings_AttachedImages_PostingAttachedImageID PRIMARY KEY (PostingAttachedImageID);
GO

ALTER TABLE [dbo].[Postings_AttachedImages]
ADD CONSTRAINT FK_Postings_AttachedImages_PostingID FOREIGN KEY (PostingID) REFERENCES dbo.Postings(PostingID);
GO

CREATE NONCLUSTERED INDEX NCIX_Postings_AttachedImages_PostingID 
ON dbo.Postings_AttachedImages(PostingID ASC);
GO


USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[PostingInThreadID_AttachedAssets]    Script Date: 11/03/2017 2:25:00 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PostingInThreadID_AttachedImages](
	[PostingInThreadIDAttachedImagesID] BIGINT IDENTITY(-9223372036854775808, 1) NOT NULL,
	[PostingInThreadID] BIGINT NOT NULL,
	[ImageID] BIGINT NOT NULL
) ON [PRIMARY]
GO

ALTER TABLE dbo.PostingInThreadID_AttachedImages
ADD CONSTRAINT PK_PostingInThreadID_AttachedImages_PostingInThreadIDAttachedImagesID PRIMARY KEY (PostingInThreadIDAttachedImagesID);
GO

ALTER TABLE dbo.PostingInThreadID_AttachedImages
ADD CONSTRAINT FK_PostingInThreadID_AttachedImages_PostingInThreadID FOREIGN KEY (PostingInThreadID) REFERENCES dbo.PostingsInThreads(PostingInThreadID);
GO

CREATE NONCLUSTERED INDEX NCIX_PostingInThreadID_AttachedImages_PostingInThreadID 
ON dbo.PostingInThreadID_AttachedImages(PostingInThreadID ASC);
GO


USE ReadWrite_Prod;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'dbo.Postings_Add_ImagesToPosting', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.Postings_Add_ImagesToPosting AS SELECT 1;');
END;
GO
/*********************************************************************************
THIS SPROC ATTACHES ANY IMAGES TO A REPLY TO A POSTING.
AT THE MOST, 20 IMAGES PER POSTING FOR NOW
*********************************************************************************/
ALTER PROC dbo.Postings_Add_ImagesToPosting(
	@PostingID BIGINT
	, @ImagesString NVARCHAR(4000)
	, @UserID BIGINT
) AS


DECLARE @ImagesAttached TINYINT;
	

INSERT INTO dbo.Postings_AttachedImages(PostingID, ImageID)
SELECT TOP (20) @PostingID, I.ImageID
FROM dbo.fn_break_string_in_brackets(@ImagesString) AS ISB
INNER JOIN dbo.Images AS I WITH(NOLOCK) ON CAST(ISB.Items AS BIGINT) = I.[ImageId]
WHERE I.UserID = @UserID
	AND I.Active = 1;
	

SET @ImagesAttached = @@ROWCOUNT;


UPDATE dbo.Postings
SET AttachedImagesCount = @ImagesAttached
WHERE PostingID = @PostingID;





GO
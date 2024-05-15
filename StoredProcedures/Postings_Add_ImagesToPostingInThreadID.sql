USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[User_PostMessageResponse]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

IF OBJECT_ID(N'dbo.Postings_Add_ImagesToPostingInThreadID', N'P') IS NULL BEGIN
	EXEC(N'CREATE PROC dbo.Postings_Add_ImagesToPostingInThreadID AS SELECT 1;');
END;
GO
/*********************************************************************************
THIS SPROC ATTACHES ANY IMAGES TO A REPLY TO A POSTING.
*********************************************************************************/
ALTER PROC dbo.Postings_Add_ImagesToPostingInThreadID(
	@PostingInThreadID BIGINT
	, @ImagesString NVARCHAR(4000)
	, @UserID BIGINT
) AS


INSERT INTO dbo.PostingInThreadID_AttachedImages(PostingInThreadID, ImageID)
SELECT @PostingInThreadID, I.ImageID
FROM dbo.fn_break_string_in_brackets(@ImagesString) AS ISB
INNER JOIN dbo.Images AS I WITH(NOLOCK) ON ISB.Items = I.[Image]
WHERE I.UserID = @UserID
	AND I.Active = 1;


GO
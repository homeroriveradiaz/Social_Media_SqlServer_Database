USE ReadWrite_Prod;
GO

/****** Object:  StoredProcedure [dbo].[Get_PostingsThatBelongToUser]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER VIEW dbo.vw_postings_raw_data_for_search_lists
AS

SELECT 
	/* These columns are intended for display to the caller */
	P.PostingID, P.PostingTitle, P.PostingMessage
	, P.Price
	, U.AvatarImageURL AS Avatar, P.PostedByUserID, U.[Name]
	, C.CurrencySymbol, C.CurrencyAbbreviation
	, (
		SELECT TOP (1) UPK.ShortenedNameFull
		FROM dbo.UsersPublicKey AS UPK 
		WHERE UPK.UserID = P.PostedByUserID
		ORDER BY UPK.ShortenedNameID DESC
	) AS UserPublicKey
	/* This is not intended for display; it should be used as a parameter of function dbo.fnha_ui_how_long_since_posting  and display to the API endpoint under the name "PostedOn" */
	, P.PostDateTime
	/* This is not intended for display; it should be placed in a count function in order to get all attachments that come with the posting under the name "SumOfAttachments" */
	, P.AttachedImagesCount
	, P.PostingTypeID
	, P.Active AS PostingActive
	, P.Censored AS PostingCensored
	, U.Active AS PostingUserActive
	, U.Censored AS PostingUserCensored
FROM dbo.Postings AS P WITH(NOLOCK)
	INNER JOIN dbo.Users AS U WITH(NOLOCK) ON P.PostedByUserID = U.UserID 
	LEFT JOIN dbo.Currencies AS C WITH(NOLOCK) ON P.PriceCurrencyID = C.CurrencyID

GO


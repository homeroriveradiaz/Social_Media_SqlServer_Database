CREATE TABLE dbo.ArticleSectionType(
	ArticleSectionTypeID TINYINT NOT NULL IDENTITY(0, 1)
	, ArticleSectionDescription NVARCHAR(300) NOT NULL
	, ArticleSectionAbbreviation VARCHAR(5) NOT NULL
);
GO
ALTER TABLE dbo.ArticleSectionType
ADD CONSTRAINT PK_ArticleSectionTypeID PRIMARY KEY (ArticleSectionTypeID);
GO


--SET IDENTITY_INSERT dbo.ArticleSectionType ON;

--INSERT INTO dbo.ArticleSectionType(ArticleSectionTypeID, ArticleSectionAbbreviation, ArticleSectionDescription)
--VALUES (0, 'HL', N'Headline. Text is the largest and appropriate for headline.')
--	, (1, 'SHL', N'Subheadline. ')
--	, (2, 'BA', N'By author.')
--	, (3, 'LTP', N'Link to business profile. Something like "Learn more about company X in this link."')
--	, (4, 'IP', N'Initial paragraph. The initial paragraph is supposed to feature a large initial character, and the rest of the text just normal.')
--	, (5, 'NP', N'Normal paragraph. Is a paragraph featuring just normal text and no special starting or ending.')
--	, (6, 'EP', N'Ending paragraph. Is a pragraph featuring normal text, but will include a special ending character.')
--	, (7, 'QFA', N'Quotation from the same article. If the article is too long, this helps as a highlight of what reader will find if he/she keeps reading. This is done with a larger than normal text.')
--	, (8, 'YTEV', N'YouTube embeded video.')
--	, (9, 'ORA', N'Other recommended articles. Used best at the end to keep the reader engaged.');

--SET IDENTITY_INSERT dbo.ArticleSectionType OFF;

--GO



CREATE TABLE dbo.VisitSections
(
	VisitingSectionID SMALLINT NOT NULL IDENTITY(1,1)
	, SectionDescription NVARCHAR(1000) NOT NULL
);

--SET IDENTITY_INSERT dbo.VisitSections ON;
--INSERT INTO dbo.VisitSections(VisitingSectionID, SectionDescription)
--VALUES
--(1,'User Profile')
--, (2, 'Article')
--, (3, 'Hashtag search list')
--, (4, 'Main page')
--, (5, 'Session Search page')
--, (6, 'Session Profile page')
--, (7, 'Single posting - Profile')
--SET IDENTITY_INSERT dbo.VisitSections OFF;

GO


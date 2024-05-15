USE [ReadWrite_Prod]
GO
/****** Object:  User [daadm_DonMcLean]    Script Date: 27/09/2017 11:53:22 p. m. ******/
CREATE USER [daadm_DonMcLean] FOR LOGIN [daadm_DonMcLean] WITH DEFAULT_SCHEMA=[daadm_DonMcLean]
GO
ALTER ROLE [db_owner] ADD MEMBER [daadm_DonMcLean]
GO
/****** Object:  Schema [daadm_DonMcLean]    Script Date: 27/09/2017 11:53:22 p. m. ******/
CREATE SCHEMA [daadm_DonMcLean]
GO


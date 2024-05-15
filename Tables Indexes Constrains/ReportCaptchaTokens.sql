USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[ReportCaptchaTokens]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ReportCaptchaTokens](
	[ReportCapthaTokenID] [bigint] IDENTITY(-9223372036854775808,1) NOT NULL,
	[Captcha] [varchar](7) NULL,
	[CaptchaCreationDate] [smalldatetime] NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
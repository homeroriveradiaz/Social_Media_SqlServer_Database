USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[CaptchaUserRelationship]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CaptchaUserRelationship](
	[CaptchaID] [bigint] IDENTITY(-9223372036854775808,1) NOT NULL,
	[UserID] [bigint] NOT NULL,
	[Captcha] [varchar](50) NOT NULL,
	[CaptchaDate] [smalldatetime] NOT NULL,
	[Identified] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CaptchaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
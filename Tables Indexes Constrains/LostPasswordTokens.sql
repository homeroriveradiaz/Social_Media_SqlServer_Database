USE ReadWrite_Prod;
GO

/****** Object:  Table [dbo].[LostPasswordTokens]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LostPasswordTokens](
	[LostPasswordRowID] [bigint] IDENTITY(-9223372036854775808,1) NOT NULL,
	[UserID] [bigint] NULL,
	[Token] [nvarchar](100) NULL,
	[ExpirationDateTime] [datetime] NULL
) ON [PRIMARY]

GO
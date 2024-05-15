USE ReadWrite_Prod;
GO
/****** Object:  Table [dbo].[CurrenciesGeography]    Script Date: 27/09/2017 11:53:23 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CurrenciesGeography](
	[RowID] [int] IDENTITY(1,1) NOT NULL,
	[CurrencyID] [int] NULL,
	[CountryID] [int] NULL,
	[StateID] [int] NULL,
	[FromDate] [smalldatetime] NULL,
	[ToDate] [smalldatetime] NULL,
	[UpdateTimestamp] [datetime] NULL,
	[Active] [bit] NULL
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[CurrenciesGeography]  WITH CHECK ADD  CONSTRAINT [FK_Currencies_CurrencyID] FOREIGN KEY([CurrencyID])
REFERENCES [dbo].[Currencies] ([CurrencyID])
GO
ALTER TABLE [dbo].[CurrenciesGeography] CHECK CONSTRAINT [FK_Currencies_CurrencyID]
GO

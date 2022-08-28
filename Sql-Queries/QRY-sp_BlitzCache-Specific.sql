exec master..sp_BlitzCache @OnlyQueryHashes = '0x6C6C838BC8A9F0A7'
exec master..sp_BlitzCache @OnlySqlHandles = ''
exec master..sp_BlitzCache @DatabaseName = 'ClientService', @StoredProcName = 'USP_UI_Get_Equity_PNLQuicko'

/*
EXEC [dbo].[GetGainersandlosers]  @FromGainLossPercent = $-99999.0000, @Party_code = 'A470041', @ToGainlossPercent = $99999.0000
*/
exec master..sp_BlitzCache @OnlyQueryHashes = '0x9FBD6F333D226376'
exec master..sp_BlitzCache @OnlySqlHandles = ''
exec master..sp_BlitzCache @DatabaseName = 'ClientService', @StoredProcName = 'GetGainersandlosers'

/*
EXEC [dbo].[GetGainersandlosers]  @FromGainLossPercent = $-99999.0000, @Party_code = 'A470041', @ToGainlossPercent = $99999.0000
*/
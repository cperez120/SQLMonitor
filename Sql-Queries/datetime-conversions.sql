DECLARE @db_name varchar(50);
set @db_name = DB_NAME();

declare @start_time datetime = dateadd(MINUTE,-45,getdate());
declare @end_time datetime = getdate();
declare @start_time_utc datetime = dateadd(MINUTE,-45,getutcdate());
declare @end_time_utc datetime = getutcdate();

select [@start_time] = @start_time, [@end_time] = @end_time, [@start_time_utc] = @start_time_utc, [@end_time_utc] = @end_time_utc;

select	[SYSDATETIMEOFFSET] = SYSDATETIMEOFFSET(), 
		[SYSDATETIME] = SYSDATETIME(), 
		[SYSUTCDATETIME] = SYSUTCDATETIME(), 
		[datetime2-converted] = CONVERT(datetime2,SYSDATETIMEOFFSET()),
		[datetimeoffset-converted] = TODATETIMEOFFSET(SYSDATETIME(),DATEPART(TZOFFSET, SYSDATETIMEOFFSET())),
		[datetime2-conversion-valid] = case when CONVERT(datetime2,SYSDATETIMEOFFSET()) = SYSDATETIME() then 'true' else 'false' end,
		[datetimeoffset-conversion-valid] = case when TODATETIMEOFFSET(SYSDATETIME(),DATEPART(TZOFFSET, SYSDATETIMEOFFSET())) = SYSDATETIMEOFFSET() then 'true' else 'false' end,
		[@start_time_utc-to-local] = DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), @start_time_utc),
		[@start_time-to-utc] = DATEADD(mi, DATEDIFF(mi, getdate(), getutcdate()), @start_time)

/*
Grafana Variables
$__timeFrom()
$__timeTo()

https://grafana.com/docs/grafana/latest/variables/advanced-variable-format-options/


*/

use DBA
go

if object_id('[dbo].[performance_counters_hourly]') is not null
	drop table [dbo].[performance_counters_hourly]
go

if object_id('[dbo].[performance_counters_hourly]') is null
begin
	create table [dbo].[performance_counters_hourly]
	(
		[collection_time_utc] [datetime2](7) NOT NULL,
		--[collection_time_utc] [datetime] NOT NULL,
		[host_name] [varchar](255) NOT NULL,
		[object] [varchar](255) NOT NULL,
		[counter] [varchar](255) NOT NULL,
		[value] numeric(38,10) NULL,
		[instance] [varchar](255) NULL
	) on ps_dba_datetime2_hourly ([collection_time_utc])
	--) on ps_dba_datetime_hourly ([collection_time_utc])
end
go

if not exists (select * from sys.indexes where [object_id] = OBJECT_ID('[dbo].[performance_counters_hourly]') and name = 'ci_performance_counters_hourly')
begin
	create clustered index ci_performance_counters_hourly on [dbo].[performance_counters_hourly] 
	([collection_time_utc], [host_name], object, counter, [instance], [value]) 
	on ps_dba_datetime2_hourly ([collection_time_utc])
	--on ps_dba_datetime_hourly ([collection_time_utc])
end
go
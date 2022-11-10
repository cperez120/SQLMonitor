declare @sql nvarchar(max);
declare @params nvarchar(max);
declare @sql_instance varchar(255);
declare @perfmon_host_name varchar(255);
declare @start_time_utc datetime2;
declare @end_time_utc datetime2;
--declare @delta_minutes int;

set @sql_instance = 'SqlPractice';
--set @perfmon_host_name = '$perfmon_host_name';
set @start_time_utc = '2022-11-10T07:00:57Z';
--set @start_time_utc = dateadd(second,1668023592450/1000,'1970-01-01 00:00:00');
set @end_time_utc = '2022-11-10T09:00:57Z';
--set @end_time_utc = '2022-11-10T07:00:57Z';
--set @delta_minutes = $cpu_delta_minutes;
set @params = N'@perfmon_host_name varchar(255), @start_time_utc datetime2, @end_time_utc datetime2';

set quoted_identifier off;
set @sql = "
set nocount on;
declare @FileIOStatsTop tinyint = 10;
declare @StatsPercentTop int = 99;

;WITH [Stats] AS
(
	SELECT	[collection_time_utc],
			[database_name],
			--[database_id],
			[file_logical_name],
			--[file_id],
			[file_location],
			[sample_ms_delta],
			--[num_of_reads],
			[read_write_bytes_delta],
			[read_writes_delta],
			[read_bytes_delta],
			--[io_stall_read_ms],
			--[io_stall_queued_read_ms],
			--[num_of_writes],
			[writes_bytes_delta],
			--[io_stall_write_ms],
			--[io_stall_queued_write_ms],
			--[io_stall],
			[io_stall_delta],
			--[size_on_disk_bytes],
			--[io_pending_count],
			--[io_pending_ms_ticks_total],
			--[io_pending_ms_ticks_avg],
			--[io_pending_ms_ticks_max],
			--[io_pending_ms_ticks_min]
			[StatsRank] = ROW_NUMBER() OVER(PARTITION BY [collection_time_utc] ORDER BY read_writes_delta DESC),
			[Percentage] = ((100.0 * [read_writes_delta]) / (SUM ([read_writes_delta]) OVER (PARTITION BY [collection_time_utc]))),
			[PercentageTotal] = ( (100.0 * ( SUM([read_writes_delta]) 
											 OVER(PARTITION BY [collection_time_utc] 
											 ORDER BY [read_writes_delta] DESC, [io_stall_delta] desc) )
								  ) / (SUM ([read_writes_delta]) OVER (PARTITION BY [collection_time_utc])) )
	FROM dbo.[vw_file_io_stats_deltas] AS [Stats]
	WHERE collection_time_utc between @start_time_utc and @end_time_utc
	
)
SELECT	time = [collection_time_utc]
		--,[database_name]
		,[metric] =  [database_name]+ ' (__ '+[file_logical_name]+' __)'
		--,[file_logical_name]
		--,[file_location]
		--,[sample_ms_delta]
		--,[read_write_bytes_delta]
		--,[read_bytes_delta]
		--,[writes_bytes_delta]
		--,[StatsRank]
		--,[Percentage]
		--,[PercentageTotal]
		,[value] = [read_writes_delta]
FROM [Stats] as cur
WHERE [StatsRank] <= @FileIOStatsTop
AND [PercentageTotal] <= @StatsPercentTop
ORDER BY [time] ASC, [read_writes_delta] DESC, [io_stall_delta] DESC
OPTION(RECOMPILE);
"
set quoted_identifier on;

--if (@sql_instance = SERVERPROPERTY('SERVERNAME'))
if (0 = 1)
  exec dbo.sp_executesql @sql, @params, @perfmon_host_name, @start_time_utc, @end_time_utc;
else
  exec [SqlPractice].[DBA].dbo.sp_executesql @sql, @params, @perfmon_host_name, @start_time_utc, @end_time_utc;
declare @sql nvarchar(max);
declare @params nvarchar(max);
declare @sql_instance varchar(255);
declare @perfmon_host_name varchar(255);
declare @start_time_utc datetime2;
declare @end_time_utc datetime2;
--declare @delta_minutes int;

set @sql_instance = 'SqlPractice';
--set @perfmon_host_name = '$perfmon_host_name';
--set @start_time_utc = '2022-11-10T06:29:34Z';
set @start_time_utc = dateadd(second,1668023592450/1000,'1970-01-01 00:00:00');
--set @end_time_utc = '2022-11-10T07:29:34Z';
set @end_time_utc = '2022-11-10T06:29:34Z';
--select @start_time_utc as start_time, @end_time_utc as end_time;
--set @delta_minutes = $cpu_delta_minutes;
set @params = N'@perfmon_host_name varchar(255), @start_time_utc datetime2, @end_time_utc datetime2';

set quoted_identifier off;
set @sql = "
set nocount on;
declare @schedulers smallint;
declare @StatstatsTop tinyint = 10;
declare @StatsPercentTop int = 99;
declare @collect_time_utc_snap1 datetime2;
declare @collect_time_utc_snap2 datetime2;

--select @start_time_utc = DATEADD(mi, DATEDIFF(mi, getdate(), getutcdate()), sqlserver_start_time) from sys.dm_os_sys_info;
select @schedulers = count(*) from sys.dm_os_schedulers where status = 'VISIBLE ONLINE' and is_online = 1;

select top 1 @collect_time_utc_snap2 = collection_time_utc
from dbo.file_io_stats s2
where s2.collection_time_utc <= @end_time_utc
order by collection_time_utc desc;

select top 1 @collect_time_utc_snap1 = collection_time_utc
from dbo.file_io_stats s1
where collection_time_utc >= @start_time_utc
order by collection_time_utc asc;

--select @collect_time_utc_snap1, @collect_time_utc_snap2;

;WITH [DiffStats] AS
(	SELECT	-- Stats that weren't in the first snapshot
			--[ts2].[collection_time_utc],
			[ts2].[database_name],
			[ts2].[database_id],
			[ts2].[file_logical_name],
			[ts2].[file_id],
			[ts2].[file_location],
			[ts2].[sample_ms],
			[ts2].[num_of_reads],
			[ts2].[num_of_bytes_read],
			[ts2].[io_stall_read_ms],
			[ts2].[io_stall_queued_read_ms],
			[ts2].[num_of_writes],
			[ts2].[num_of_bytes_written],
			[ts2].[io_stall_write_ms],
			[ts2].[io_stall_queued_write_ms],
			[ts2].[io_stall],
			[ts2].[size_on_disk_bytes],
			[ts2].[io_pending_count]
	FROM dbo.file_io_stats AS [ts2]
	LEFT OUTER JOIN dbo.file_io_stats AS [ts1]
		ON [ts2].[database_name] = [ts1].[database_name]
		AND [ts2].[file_logical_name] = [ts1].[file_logical_name]
		AND [ts2].collection_time_utc = @collect_time_utc_snap2
		AND [ts1].collection_time_utc = @collect_time_utc_snap1
	WHERE [ts1].[file_logical_name] IS NULL
	AND [ts2].collection_time_utc = @collect_time_utc_snap2
	--
	UNION
	--
	SELECT	-- Diff of Stats in both snapshots
			--[collection_time_utc] = [ts2].[collection_time_utc] - [ts1].[collection_time_utc],
			[database_name] = [ts2].[database_name],
			[database_id] = [ts2].[database_id],
			[file_logical_name] = [ts2].[file_logical_name],
			[file_id] = [ts2].[file_id],
			[file_location] = [ts2].[file_location],
			[sample_ms] = [ts2].[sample_ms] - [ts1].[sample_ms],
			[num_of_reads] = [ts2].[num_of_reads] - [ts1].[num_of_reads],
			[num_of_bytes_read] = [ts2].[num_of_bytes_read] - [ts1].[num_of_bytes_read],
			[io_stall_read_ms] = [ts2].[io_stall_read_ms] - [ts1].[io_stall_read_ms],
			[io_stall_queued_read_ms] = [ts2].[io_stall_queued_read_ms] - [ts1].[io_stall_queued_read_ms],
			[num_of_writes] = [ts2].[num_of_writes] - [ts1].[num_of_writes],
			[num_of_bytes_written] = [ts2].[num_of_bytes_written] - [ts1].[num_of_bytes_written],
			[io_stall_write_ms] = [ts2].[io_stall_write_ms] - [ts1].[io_stall_write_ms],
			[io_stall_queued_write_ms] = [ts2].[io_stall_queued_write_ms] - [ts1].[io_stall_queued_write_ms],
			[io_stall] = [ts2].[io_stall] - [ts1].[io_stall],
			[size_on_disk_bytes] = [ts2].[size_on_disk_bytes],
			[io_pending_count] = [ts2].[io_pending_count] - [ts1].[io_pending_count]
	FROM dbo.file_io_stats AS [ts2]
	LEFT OUTER JOIN dbo.file_io_stats AS [ts1]
		ON [ts2].[database_name] = [ts1].[database_name]
		AND [ts2].[file_logical_name] = [ts1].[file_logical_name]
		AND [ts2].collection_time_utc = @collect_time_utc_snap2
		AND [ts1].collection_time_utc = @collect_time_utc_snap1
	WHERE [ts1].[file_logical_name] IS NOT NULL
	AND ( ([ts2].[num_of_reads]+[ts2].[num_of_writes]) - ([ts1].[num_of_reads]+[ts1].[num_of_writes]) ) > 0
	AND [ts2].collection_time_utc = @collect_time_utc_snap2
)
,[t_DiskDrives] AS 
(	select ds.disk_volume
	from dbo.disk_space ds
	where ds.collection_time_utc = (select max(i.collection_time_utc) from dbo.disk_space i)
)
,[t_FileIO] AS
(	SELECT	[running_query] = 'File IO Stats', [sample_ms], [database_name], 
			[file_name_DISPLAY] = [file_logical_name]+' '+QUOTENAME(case when right(file_location,3) = 'ldf' then 'LOG' else 'DATA' end),
			[file_logical_name], [file_location], dv.disk_volume, [size_on_disk_bytes],
			[file_type] = case when right(file_location,3) = 'ldf' then 'LOG' else 'DATA' end,

			[total_reads_writes] = [num_of_reads] + [num_of_writes], 
			[num_of_bytes_read], [num_of_bytes_written], 
			[total_reads_writes_bytes] = [num_of_bytes_read]+[num_of_bytes_written],
			
			[reads_pcnt] = convert(numeric(20,2),case when [num_of_bytes_read] = 0 and [num_of_bytes_written] = 0 then 0
								else 100.0 * ([num_of_bytes_read]*1.0)/([num_of_bytes_read]+[num_of_bytes_written]) end),
			[writes_pcnt] = convert(numeric(20,2),case when [num_of_bytes_read] = 0 and [num_of_bytes_written] = 0 then 0
								else 100.0 * ([num_of_bytes_written]*1.0)/([num_of_bytes_read]+[num_of_bytes_written]) end),
			[pcnt_reads_writes] = convert(varchar,convert(numeric(20,2),case when [num_of_bytes_read] = 0 and [num_of_bytes_written] = 0 then 0
								else 100.0 * ([num_of_bytes_read]*1.0)/([num_of_bytes_read]+[num_of_bytes_written]) end)) + ' / ' + convert(varchar,convert(numeric(20,2),case when [num_of_bytes_read] = 0 and [num_of_bytes_written] = 0 then 0
								else 100.0 * ([num_of_bytes_written]*1.0)/([num_of_bytes_read]+[num_of_bytes_written]) end)),

			--[num_of_reads], [io_stall_read_ms], [num_of_writes],  [io_stall_write_ms],
			--[io_stall], [io_pending_ms_ticks_total],
			
			[read_latency_ms] = convert(numeric(20,2), case when [num_of_reads] = 0 then 0 else (([io_stall_read_ms] * 1.0)/[num_of_reads]) end),
			[write_latency_ms] = convert(numeric(20,2), case when [num_of_writes] = 0 then 0 else (([io_stall_write_ms] * 1.0)/[num_of_writes]) end),
			[latency_ms] = convert(numeric(20,2), case when [num_of_reads] + [num_of_writes] = 0 then 0 else (([io_stall] * 1.0) / ([num_of_reads] + [num_of_writes])) end),

			[avg_bytes_per_read] = convert(numeric(20,2), case when [num_of_reads] = 0 then 0 else ( ([num_of_bytes_read] * 1.0) / [num_of_reads] ) end),
			[avg_bytes_per_write] = convert(numeric(20,2), case when [num_of_writes] = 0 then 0 else ( ([num_of_bytes_written] * 1.0) / [num_of_writes] ) end),
			[avg_bytes_per_transfer] = convert(numeric(20,2), case when [num_of_reads] = 0 and [num_of_writes] = 0 then 0 else ( (([num_of_bytes_read]+[num_of_bytes_written]) * 1.0) / ([num_of_reads]+[num_of_writes]) ) end)
	FROM [DiffStats] fis
	OUTER APPLY (
			select top 1 dd.disk_volume
			from [t_DiskDrives] dd
			where fis.file_location like (dd.disk_volume+'%')
			order by len(dd.disk_volume) desc
		) dv
)
select *
from [t_FileIO] fio
order by ([num_of_bytes_read]+[num_of_bytes_written]) desc
"
set quoted_identifier on;

--if (@sql_instance = SERVERPROPERTY('SERVERNAME'))
if (0 = 1)
  exec dbo.sp_executesql @sql, @params, @perfmon_host_name, @start_time_utc, @end_time_utc;
else
  exec [SqlPractice].[DBA].dbo.sp_executesql @sql, @params, @perfmon_host_name, @start_time_utc, @end_time_utc;
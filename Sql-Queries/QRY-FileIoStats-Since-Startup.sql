use DBA
go

declare @sql nvarchar(max);
declare @params nvarchar(max);
declare @sql_instance varchar(255);
--declare @perfmon_host_name varchar(255);
declare @start_time_utc datetime2;
declare @end_time_utc datetime2;
--declare @delta_minutes int;

set @sql_instance = 'SqlMonitor';
--set @perfmon_host_name = '$perfmon_host_name';
set @start_time_utc = '2022-11-09T05:12:39Z';
set @end_time_utc = '2022-11-09T08:12:39Z';
--set @delta_minutes = $cpu_delta_minutes;
set @params = N'@start_time_utc datetime2, @end_time_utc datetime2';

set quoted_identifier off;
set @sql = "/* SQLMonitor - File IO Stats Since Startup */
set nocount on;
declare @start_time datetime;
declare @schedulers smallint;
declare @cpu_time_min decimal(18,1);
declare @IOStatsTop tinyint = 10;
declare @IOPercentTop int = 99;

select @start_time = sqlserver_start_time from sys.dm_os_sys_info;
select @schedulers = count(*) from sys.dm_os_schedulers where status = 'VISIBLE ONLINE' and is_online = 1;
-- @cpu_time_min = sum(total_cpu_usage_ms/1000.0)/60.0

;WITH [t_DiskDrives] AS (
	select ds.disk_volume
	from dbo.disk_space ds
	where ds.collection_time_utc = (select max(i.collection_time_utc) from dbo.disk_space i)
)
,[t_FileIO] AS
	(	SELECT
	    [running_query] = 'File IO Stats', [collection_time_utc], [sample_ms], [database_name], 
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
			
			/*
			[wait_time_ms] / 1000.0 AS [WaitS],
				[wait_time_ms],
			([wait_time_ms] - [signal_wait_time_ms]) / 1000.0 AS [ResourceS],
			[signal_wait_time_ms] / 1000.0 AS [SignalS],
			[waiting_tasks_count] AS [WaitCount],
			*/

			--100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() AS [Percentage],
			--ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum]
		FROM dbo.file_io_stats fis
		OUTER APPLY (
				select top 1 dd.disk_volume
				from [t_DiskDrives] dd
				where fis.file_location like (dd.disk_volume+'%')
				order by len(dd.disk_volume) desc
			) dv
		WHERE fis.collection_time_utc = (SELECT MAX(i.collection_time_utc) FROM dbo.file_io_stats i)
    )
select *
from [t_FileIO] fio
order by ([num_of_bytes_read]+[num_of_bytes_written]) desc
"
set quoted_identifier on;


--if (@sql_instance = SERVERPROPERTY('SERVERNAME'))
if (1 = 1)
  exec dbo.sp_executesql @sql, @params, @start_time_utc, @end_time_utc;
--else
--  exec [SqlMonitor].[DBA].dbo.sp_executesql @sql, @params, @start_time_utc, @end_time_utc;

/*
Since startup
---------------

Tabular ->
> Identify the disk drives by IO
    Disk, Reads_gb, Writes_gb, DbFilesCount, DbFilesSize_gb, reads %, writes %, IO latency
> Identify the databases by IO
    Database, Disk, Reads_gb, Writes_db, DbFilesCount, DbFilesSize_gb, reads %, writes %, IO latency
> Identify db files by IO
    File, Database, Disk, Reads_gb, Writes_gb, DbFileSize_gb, reads %, writes %, Latency

Delta ->
> Same as above

Histogram ->
Time, Database, IO

Time Series ->
> Plot Disk Reads gb
    Time, Disk, reads_gb
> Plot Disk Writes gb
    Time, Disk, Writes_gb
> Plot Database Reads gb
    Time, Database, reads_gb
> Plot Database Writes gb
    Time, Database, writes_gb

*/
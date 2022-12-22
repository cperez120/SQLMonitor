/*
1) Create a folder on Grafana named "SQLServer". This name is case sensitive.
2) Then import all the dashboards using *.json files into The SQLServer folder created above.
3) Select appropriate Data Source

https://grafana.com/docs/grafana/v9.0/variables/variable-types/global-variables/
https://grafana.com/docs/grafana/v9.0/variables/advanced-variable-format-options/
https://grafana.com/docs/grafana/v9.0/variables/syntax/

d/distributed_live_dashboard?var-server=${__data.fields.srv_name}
d/wait_stats?var-server=${server}

Data Links - WaitType
https://www.sqlskills.com/help/waits/${__value.raw}

Data Links - Absolute URL
${__data.fields.url}
*/

Grafana Variables
--------------------

$__dashboard
$__timeFrom()
$__timeTo()
$__name
$__timeFilter(collection_time_utc)
collection_time_utc between $__timeFrom() and $__timeTo()
go

Disk IO Stats ____Since Startup ___ till ___ Current Time___
Disk IO Stats ____Since Startup ___ till ___ ${collection_time_utc:date:YYYY-MM-DD HH.mm}___
Disk IO Stats ____Since Startup ___ till ___ ${__from:date:YYYY-MM-DD HH.mm}___
Database IO Stats ____In Selected Time Duration____Since____${__from:date:YYYY-MM-DD HH.mm}___till___${__to:date:YYYY-MM-DD HH.mm}____
go


SELECT [DateTime]
      ,[AirTemp]
  FROM [meteoData]
  WHERE [DateTime] BETWEEN '${__from:date:iso}' AND '${__to:date:iso}'
  ORDER BY [DateTime] DESC;
GO


set @start_time_utc = dateadd(second,$sqlserver_start_time_utc/1000,'1970-01-01 00:00:00');

use DBA
go

select top 1 *
from dbo.vw_performance_counters
go

/* 
Refresh -> On dashboard load
Query -> Below
Sort -> Alphabetical (case-insensitive, asc)
Validate -> __All__ is top value in Preview

$disk_drive
$database
*/
declare @sql nvarchar(max);
declare @params nvarchar(max);
declare @sql_instance varchar(255);
declare @perfmon_host_name varchar(255);

set @sql_instance = '$server';
--set @perfmon_host_name = '$perfmon_host_name';
set @params = N'@perfmon_host_name varchar(255)';

set quoted_identifier off;
set @sql = "select ds.disk_volume as disk_drive
	from dbo.disk_space ds
	where ds.collection_time_utc = (select max(i.collection_time_utc) from dbo.disk_space i)
	union all
	select '__All__' as disk_drive
	order by disk_drive"
set quoted_identifier on;

--if (@sql_instance = SERVERPROPERTY('SERVERNAME'))
if ($is_local = 1)
  exec dbo.sp_executesql @sql , @params, @perfmon_host_name;
else
  exec [$server].[$dba_db].dbo.sp_executesql @sql , @params, @perfmon_host_name;
go


declare @sql nvarchar(max);
declare @params nvarchar(max);
declare @sql_instance varchar(255);
declare @perfmon_host_name varchar(255);

set @sql_instance = '$server';
--set @perfmon_host_name = '$perfmon_host_name';
set @params = N'@perfmon_host_name varchar(255)';

set quoted_identifier off;
set @sql = "select name from sys.databases d where d.state_desc = 'ONLINE' union all select '__All__' as name order by name;"
set quoted_identifier on;

--if (@sql_instance = SERVERPROPERTY('SERVERNAME'))
if ($is_local = 1)
  exec dbo.sp_executesql @sql , @params, @perfmon_host_name;
else
  exec [$server].[$dba_db].dbo.sp_executesql @sql , @params, @perfmon_host_name;
go

declare @disk_drive varchar(255) = '$disk_drive';
declare @database varchar(255) = '$database';

set @database = case when ltrim(rtrim(@database)) = '__All__' then null else @database end;
set @disk_drive = case when ltrim(rtrim(@disk_drive)) = '__All__' then null else @disk_drive end;

set @params = N', @disk_drive varchar(255), @database varchar(255)';
, @disk_drive, @database

/*
"+(case when @disk_drive is null then '-- ' else '' end)+"and ds.disk_volume = @disk_drive
"+(case when @disk_drive is null then '-- ' else '' end)+"and (pc.instance+'\') = @disk_drive

"+(case when @database is null then '-- ' else '' end)+"AND fis.[database_name] = @database

"+(case when @database is null then '-- ' else '' end)+"AND [Stats].[database_name] = @database
"+(case when @disk_drive is null then '-- ' else '' end)+"and [Stats].disk_volume = @disk_drive


*/
go


SELECT TOP 100 * FROM dbo.[vw_file_io_stats_deltas] AS [Stats]

	
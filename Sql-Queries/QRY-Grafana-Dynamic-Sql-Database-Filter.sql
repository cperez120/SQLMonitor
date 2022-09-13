declare @sql nvarchar(max);
declare @params nvarchar(max);
declare @sql_instance varchar(255) = '$server';
declare @perfmon_host_name varchar(255) = '$perfmon_host_name';
declare @start_time_utc datetime2 = $__timeFrom();
declare @end_time_utc datetime2 = $__timeTo();
declare @perfmon_object varchar(125) = '$perfmon_object';
declare @database varchar(255) = '$database';
declare @crlf nchar(2) = nchar(13)+nchar(10);

set @params = N'@perfmon_host_name varchar(255), @start_time_utc datetime2, @end_time_utc datetime2, @perfmon_object varchar(125), @database varchar(255)';
set @database = case when ltrim(rtrim(@database)) = '' then null else @database end;

set quoted_identifier off;
set @sql = "
set nocount on;
select pc.collection_time_utc as time
	,instance+' - '+counter as metric
	,pc.value
from $perfmon_table_name pc with (nolock)
where collection_time_utc between @start_time_utc and @end_time_utc
and pc.host_name = @perfmon_host_name and pc.object = (@perfmon_object+':Databases')
and pc.counter in ('Log Flush Waits/sec','Log Flushes/sec','Log Growths','Log Shrinks','Log Truncations','Percent Log Used')";
if @database is null
	set @sql = @sql + @crlf + "and pc.instance not in ('_Total','master','model','mssqlsystemresource')";
else
	set @sql = @sql + @crlf + "and pc.instance = @database";
set @sql = @sql + @crlf + "order by time";
set quoted_identifier on;

if (@sql_instance = SERVERPROPERTY('SERVERNAME'))
  exec dbo.sp_executesql @sql , @params, @perfmon_host_name, @start_time_utc, @end_time_utc, @perfmon_object, @database;
else
  exec [$server].[$dba_db].dbo.sp_executesql @sql , @params, @perfmon_host_name, @start_time_utc, @end_time_utc, @perfmon_object, @database;

go
/*
where collection_time_utc between @start_time_utc and @end_time_utc
and pc.host_name = @perfmon_host_name and pc.object = (@perfmon_object+':Databases')
*/
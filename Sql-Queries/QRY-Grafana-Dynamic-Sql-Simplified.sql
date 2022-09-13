declare @sql nvarchar(max);
declare @params nvarchar(max);
declare @sql_instance varchar(255) = '$server';
declare @perfmon_host_name varchar(255) = '$perfmon_host_name';
declare @start_time_utc datetime2 = $__timeFrom();
declare @end_time_utc datetime2 = $__timeTo();
declare @perfmon_object varchar(125) = '$perfmon_object';
declare @crlf nchar(2) = nchar(13)+nchar(10);

set @params = N'@perfmon_host_name varchar(255), @start_time_utc datetime2, @end_time_utc datetime2, @perfmon_object varchar(125)';

set quoted_identifier off;
set @sql = "
set nocount on;
select pc.collection_time_utc as time
	,counter+' ('+instance+')' as metric
	,pc.value
from $perfmon_table_name pc with (nolock)
where collection_time_utc between @start_time_utc and @end_time_utc
and pc.host_name = @perfmon_host_name 
and pc.object = 'SQLAgent:Jobs' and pc.counter in ('Active jobs','Failed jobs','Successful jobs') and pc.instance = '_total'
order by time
"
set quoted_identifier on;

if (@sql_instance = SERVERPROPERTY('SERVERNAME'))
  exec dbo.sp_executesql @sql , @params, @perfmon_host_name, @start_time_utc, @end_time_utc, @perfmon_object;
else
  exec [$server].[$dba_db].dbo.sp_executesql @sql , @params, @perfmon_host_name, @start_time_utc, @end_time_utc, @perfmon_object;

go
/*
where collection_time_utc between @start_time_utc and @end_time_utc
and pc.host_name = @perfmon_host_name and pc.object = (@perfmon_object+':Latches')
*/
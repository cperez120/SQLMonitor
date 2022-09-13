declare @sql nvarchar(max);
declare @params nvarchar(max);
declare @sql_instance varchar(255);
declare @perfmon_host_name varchar(255);
declare @start_time_utc datetime2;
declare @end_time_utc datetime2;
declare @crlf nchar(2) = nchar(13)+nchar(10);

--declare @delta_minutes int;
declare @program_name nvarchar(500);
declare @login_name nvarchar(255);
declare @database nvarchar(500);
declare @session_id int;
declare @session_host_name nvarchar(125);
declare @query_pattern nvarchar(500);
declare @duration int;

set @duration = case when ltrim(rtrim('$duration')) <> '' then $duration else 0 end;
if len(ltrim(rtrim('$program_name'))) > 0
  set @program_name = '$program_name'
if len(ltrim(rtrim('$login_name'))) > 0
  set @login_name = '$login_name'
if len(ltrim(rtrim('$database'))) > 0
  set @database = '$database'
if len(ltrim(rtrim('$session_host_name'))) > 0
  set @session_host_name = '$session_host_name'
if len(ltrim(rtrim('$query_pattern'))) > 0
  set @query_pattern = '$query_pattern'
if len(ltrim(rtrim('$session_id'))) > 0 and (case when '$session_id' like '%[^0-9.]%' then 'invalid' when '$session_id' like '%.%.%' then 'invalid' else 'valid' end) = 'valid'
  set @session_id = convert(int,'$session_id');

set @sql_instance = '$server';
--set @perfmon_host_name = '$perfmon_host_name';
set @start_time_utc = $__timeFrom();
--set @start_time_utc = dateadd(second,$sqlserver_start_time_utc/1000,'1970-01-01 00:00:00');
set @end_time_utc = $__timeTo();
--set @end_time_utc = $__timeFrom();
--set @delta_minutes = $cpu_delta_minutes;
set @params = N'@perfmon_host_name varchar(255), @start_time_utc datetime2, @end_time_utc datetime2,
				@program_name nvarchar(500), @login_name nvarchar(255), @database nvarchar(500),
				@session_id int, @session_host_name nvarchar(125), @query_pattern nvarchar(500),
				@duration int';

set quoted_identifier off;
set @sql = "
set nocount on;

;with cte_sessions as (
  select [collection_time] = DATEADD(mi, DATEDIFF(mi, getdate(), getutcdate()), w.collection_time), w.session_id, 
  		w.[dd hh:mm:ss.mss], w.program_name, w.login_name, w.database_name, w.host_name,
  		w.status, w.CPU, w.used_memory, w.open_tran_count, 
  		w.wait_info, 
  		sql_command = case when w.sql_command is not null then left(replace(replace(convert(nvarchar(max),w.sql_command),char(13)+char(10),''),'<?query --',''),150)
  							else left(replace(replace(convert(nvarchar(max),w.sql_text),char(13)+char(10),''),'<?query --',''),150) end, 
  		w.blocked_session_count, 
  		w.blocking_session_id, w.reads, w.writes, w.tempdb_allocations, 
  		w.tasks, w.percent_complete, start_time = convert(varchar,w.start_time,120)
  from $whoisactive_table_name w with (nolock)
  where w.collection_time between DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), @start_time_utc) and DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), @end_time_utc)
)
select *
from cte_sessions w
where 1 = 1
"

if @program_name is not null
	set @sql = @sql + @crlf + "and w.program_name like ('%'+@program_name+'%')"
if @database is not null
	set @sql = @sql + @crlf + "and w.database_name like ('%'+@database+'%')"
if @login_name is not null
	set @sql = @sql + @crlf + "and w.login_name like ('%'+@login_name+'%')"
if @session_host_name is not null
	set @sql = @sql + @crlf + "and w.host_name like ('%'+@session_host_name+'%')"
if @query_pattern is not null
	set @sql = @sql + @crlf + "and w.sql_command like ('%'+@query_pattern+'%')"
if @session_id is not null
	set @sql = @sql + @crlf + "and w.session_id = @session_id"
set @sql = @sql + @crlf + "order by w.collection_time DESC, w.start_time ASC";

set quoted_identifier on;
--print @sql

if (@sql_instance = SERVERPROPERTY('SERVERNAME'))
  exec dbo.sp_executesql @sql, @params, @perfmon_host_name, @start_time_utc, @end_time_utc, 
					@program_name, @login_name, @database, @session_id, @session_host_name, 
					@query_pattern, @duration;
else
  exec [$server].[$dba_db].dbo.sp_executesql @sql, @params, @perfmon_host_name, @start_time_utc, @end_time_utc,
					@program_name, @login_name, @database, @session_id, @session_host_name, 
					@query_pattern, @duration;
go

/*
-- Find block Leaders
		SELECT	*
		FROM	$whoisactive_table_name AS r with (nolock)
		WHERE	 (collection_time between DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), @start_time_utc) and DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), @end_time_utc))
		
		and collection_time_utc between @start_time_utc and @end_time_utc
*/
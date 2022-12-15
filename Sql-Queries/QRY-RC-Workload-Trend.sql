declare @sql nvarchar(max);
declare @params nvarchar(max);
declare @sql_instance varchar(255);
declare @perfmon_host_name varchar(255);
declare @start_time_utc datetime2;
declare @end_time_utc datetime2;
declare @crlf nchar(2) = nchar(13)+nchar(10);
declare @page_no int = 1;
declare @page_size int = 20;

--declare @delta_minutes int;
declare @program_name nvarchar(500);
declare @login_name nvarchar(255);
declare @database nvarchar(500) = '__All__';
declare @session_id int;
declare @session_host_name nvarchar(125);
declare @query_pattern nvarchar(500);
declare @duration int;

set @database = case when ltrim(rtrim(@database)) = '__All__' then null else @database end;
set @duration = case when ltrim(rtrim('1')) <> '' then 1 else 0 end;
if len(ltrim(rtrim(''))) > 0
  set @program_name = ''
if len(ltrim(rtrim(''))) > 0
  set @login_name = ''
if len(ltrim(rtrim(''))) > 0
  set @session_host_name = ''
if len(ltrim(rtrim(''))) > 0
  set @query_pattern = ''
if len(ltrim(rtrim(''))) > 0 and (case when '' like '%[^0-9.]%' then 'invalid' when '' like '%.%.%' then 'invalid' else 'valid' end) = 'valid'
  set @session_id = convert(int,'');

set @sql_instance = 'SqlPractice';
--set @perfmon_host_name = '$perfmon_host_name';
set @start_time_utc = dateadd(hour,-2,getutcdate());
--set @start_time_utc = dateadd(second,$sqlserver_start_time_utc/1000,'1970-01-01 00:00:00');
set @end_time_utc = GETUTCDATE();
--set @end_time_utc = '2022-12-13T13:50:10Z';
--set @delta_minutes = $cpu_delta_minutes;
set @params = N'@perfmon_host_name varchar(255), @start_time_utc datetime2, @end_time_utc datetime2,
				@program_name nvarchar(500), @login_name nvarchar(255), @database nvarchar(500),
				@session_id int, @session_host_name nvarchar(125), @query_pattern nvarchar(500),
				@duration int, @page_no int, @page_size int';

set quoted_identifier off;
set @sql = "/* SQLMonitor Dashboard WhoIsActive - SQL Server Queries - Workload: LongRunningQueries  */
set nocount on;			

;with t_resource_consumption as 
(
	select *
	from dbo.resource_consumption rc with (nolock)
	where 1=1
	and rc.event_time between DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), @start_time_utc) and DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), @end_time_utc)
	"+(case when @duration is null then '-- ' else '' end)+"and duration_seconds >= (@duration*60)
	"+(case when @program_name is null then '-- ' else '' end)+"and rc.program_name like ('%'+@program_name+'%')
	"+(case when @database is null then '-- ' else '' end)+"and rc.database_name like ('%'+@database+'%')
	"+(case when @login_name is null then '-- ' else '' end)+"and rc.login_name like ('%'+@login_name+'%')
	"+(case when @session_host_name is null then '-- ' else '' end)+"and rc.host_name like ('%'+@session_host_name+'%')
	"+(case when @query_pattern is null then '-- ' else '' end)+"and rc.sql_command like ('%'+@query_pattern+'%')
	"+(case when @session_id is null then '-- ' else '' end)+"and rc.session_id like ('%'+@session_id+'%')
	order by event_time, start_time, row_id
	offset ((@page_no-1)*@page_size) rows fetch next @page_size rows only
)
select *
from t_resource_consumption w
"
set quoted_identifier on;
print @sql

--if (@sql_instance = SERVERPROPERTY('SERVERNAME'))
--if (0 = 1)
  exec dbo.sp_executesql @sql, @params, @perfmon_host_name, @start_time_utc, @end_time_utc, 
					@program_name, @login_name, @database, @session_id, @session_host_name, 
					@query_pattern, @duration, @page_no, @page_size;
--else
--  exec [SqlPractice].[DBA].dbo.sp_executesql @sql, @params, @perfmon_host_name, @start_time_utc, @end_time_utc,
--					@program_name, @login_name, @database, @session_id, @session_host_name, 
--					@query_pattern, @duration, @page_no, @page_size;
use DBA_Admin
go
declare @start_time datetime = dateadd(day,-10,getdate());
declare @database_name nvarchar(255) --= 'ACCOUNT';
declare @table_name nvarchar(500) = 'tbl_UserMasterInfo';
declare @str_length smallint = 100;
declare @end_time datetime = getdate();
declare @sql_string nvarchar(max);
declare @my_login varchar(255) = suser_name();

if object_id('tempdb..#queries') is not null drop table #queries;
CREATE TABLE #queries
(
	[grouping-key] [nvarchar](200),
	[cpu_time_minutes] [bigint],
	[cpu_time_seconds_avg] [bigint],
	[logical_reads_gb] [numeric](20, 2),
	[logical_reads_gb_avg] [numeric](20, 2),
	[logical_reads_mb_avg] [numeric](20, 2),
	[writes_gb] [numeric](20, 2),
	[writes_mb] [numeric](20, 2),
	[writes_gb_avg] [numeric](20, 2),
	[writes_mb_avg] [numeric](20, 2),
	[duration_minutes] [bigint],
	[duration_minutes_avg] [bigint],
	[duration_seconds_avg] [bigint],
	[counts] [int]
);

set quoted_identifier off;
set @sql_string = "
;with cte_group as (
	select	[grouping-key] = (case when client_app_name like 'SQL Job = %' then client_app_name else left(DBA_Admin.dbo.normalized_sql_text((case when ltrim(rc.sql_text) like 'exec sp_executesql @statement=N%' 
									then substring(ltrim(rtrim(rc.sql_text)),33,len(ltrim(rtrim(rc.sql_text)))-33)
									when ltrim(rc.sql_text) like 'exec sp_executesql%' 
									then substring(ltrim(rtrim(rc.sql_text)),22,len(ltrim(rtrim(rc.sql_text)))-22)
									when rc.sql_text like'%sp_prepexec%'
									then replace(rc.sql_text,'sp_prepexec','')
									else rc.sql_text
									end),150,0),@str_length) end), 
			[cpu_time_minutes] = sum(cpu_time/1000000)/60,
			[cpu_time_seconds_avg] = sum(cpu_time/1000000)/count(*),
			[logical_reads_gb] = convert(numeric(20,2),sum(logical_reads)*8.0/1024/1024), 
			[logical_reads_gb_avg] = convert(numeric(20,2),sum(logical_reads)*8.0/1024/1024/count(*)),
			[logical_reads_mb_avg] = convert(numeric(20,2),sum(logical_reads)*8.0/1024/count(*)),
			[writes_gb] = convert(numeric(20,2),sum(writes)*8.0/1024/1024),
			[writes_mb] = convert(numeric(20,2),sum(writes)*8.0/1024),
			[writes_gb_avg] = convert(numeric(20,2),sum(writes)*8.0/1024/1024/count(*)),
			[writes_mb_avg] = convert(numeric(20,2),sum(writes)*8.0/1024/count(*)),
			[duration_minutes] = sum(rc.duration_seconds)/60,
			[duration_minutes_avg] = sum(rc.duration_seconds)/60/count(*),
			[duration_seconds_avg] = sum(rc.duration_seconds)/count(*),
			[counts] = count(*)
			/*
			,[sql_text_ripped] = (case when ltrim(rc.sql_text) like 'exec sp_executesql @statement=N%' 
									then substring(ltrim(rtrim(rc.sql_text)),33,len(ltrim(rtrim(rc.sql_text)))-33)
									when ltrim(rc.sql_text) like 'exec sp_executesql%' 
									then substring(ltrim(rtrim(rc.sql_text)),22,len(ltrim(rtrim(rc.sql_text)))-22)
									when rc.sql_text like'%sp_prepexec%'
									then replace(rc.sql_text,'sp_prepexec','')
									else rc.sql_text
									end)
			*/
	from DBA_Admin.dbo.vw_resource_consumption rc
	where rc.event_time between @start_time and @end_time
	"+(CASE WHEN @database_name IS NULL THEN "--" ELSE "" END)+"and rc.database_name = @database_name
	and rc.sql_text like ('%'+@table_name+'%')
	and result = 'OK'
	and rc.username <> @my_login
	group by (case when client_app_name like 'SQL Job = %' then client_app_name else left(DBA_Admin.dbo.normalized_sql_text((case when ltrim(rc.sql_text) like 'exec sp_executesql @statement=N%' 
									then substring(ltrim(rtrim(rc.sql_text)),33,len(ltrim(rtrim(rc.sql_text)))-33)
									when ltrim(rc.sql_text) like 'exec sp_executesql%' 
									then substring(ltrim(rtrim(rc.sql_text)),22,len(ltrim(rtrim(rc.sql_text)))-22)
									when rc.sql_text like'%sp_prepexec%'
									then replace(rc.sql_text,'sp_prepexec','')
									else rc.sql_text
									end),150,0),@str_length) end)
)
select *
from cte_group ct
--order by [logical_reads_gb] desc
--select *
--from dbo.resource_consumption rc
--where (	rc.start_time between @start_time and @end_time or rc.event_time between @start_time and @end_time )
--order by writes_gb desc,  writes_mb_avg desc
OPTION (RECOMPILE)
"
set quoted_identifier on;

insert #queries
exec sp_ExecuteSql @sql_string, N'@database_name nvarchar(255), @start_time datetime, @end_time datetime, @str_length smallint, @table_name nvarchar(500), @my_login varchar(255)', 
					@database_name, @start_time, @end_time, @str_length, @table_name, @my_login;

set quoted_identifier off;
set @sql_string = "
select top 200 [sql_text_ripped] = (case when ltrim(rc.sql_text) like 'exec sp_executesql @statement=N%' 
									then substring(ltrim(rtrim(rc.sql_text)),33,len(ltrim(rtrim(rc.sql_text)))-33)
									when ltrim(rc.sql_text) like 'exec sp_executesql%' 
									then substring(ltrim(rtrim(rc.sql_text)),22,len(ltrim(rtrim(rc.sql_text)))-22)
									when rc.sql_text like'%sp_prepexec%'
									then replace(rc.sql_text,'sp_prepexec','')
									else rc.sql_text
									end),
		q.[grouping-key],
		rc.sql_text, q.counts, q.cpu_time_seconds_avg, q.logical_reads_gb_avg, duration_seconds_avg, 
		q.cpu_time_minutes, q.logical_reads_gb, q.duration_minutes, rc.event_name,
		rc.database_name, rc.client_app_name, rc.username, rc.client_hostname, rc.row_count
from #queries q
cross apply (select top 1 * from dbo.vw_resource_consumption rc 
			where rc.event_time between @start_time and @end_time
			"+(CASE WHEN @database_name IS NULL THEN "--" ELSE "" END)+"and rc.database_name = @database_name
			and rc.sql_text like ('%'+@table_name+'%')
			and result = 'OK'
			and q.[grouping-key] = (case when rc.client_app_name like 'SQL Job = %' then rc.client_app_name else left(DBA_Admin.dbo.normalized_sql_text((case when ltrim(rc.sql_text) like 'exec sp_executesql @statement=N%' 
									then substring(ltrim(rtrim(rc.sql_text)),33,len(ltrim(rtrim(rc.sql_text)))-33)
									when ltrim(rc.sql_text) like 'exec sp_executesql%' 
									then substring(ltrim(rtrim(rc.sql_text)),22,len(ltrim(rtrim(rc.sql_text)))-22)
									when rc.sql_text like'%sp_prepexec%'
									then replace(rc.sql_text,'sp_prepexec','')
									else rc.sql_text
									end),150,0),@str_length) end)
			--order by rc.logical_reads desc
			) rc
--where q.[grouping-key] like 'SELECT%'
--and q.[grouping-key] like '%INTO%'
--and q.[grouping-key] like '%FROM%'
--and q.[grouping-key] like '%dbo.led'
--and rc.database_name = 'ACCOUNT'
--and rc.username like 'AWS_Vendor%'
--and rc.client_app_name like 'python%'
order by [counts] desc
option (recompile)
"
set quoted_identifier on;

exec sp_ExecuteSql @sql_string, N'@database_name nvarchar(255), @start_time datetime, @end_time datetime, @str_length smallint, @table_name nvarchar(500)', 
					@database_name, @start_time, @end_time, @str_length, @table_name

--select *
--from #queries q
--where q.[grouping-key] like 'SELECT%'
--and q.[grouping-key] like '%INTO%'
--and q.[grouping-key] like '%FROM%'
--and q.[grouping-key] like '%dbo.led'

/*
select top 1000 
		sqlsig = DBA_Admin.dbo.normalized_sql_text(sql_text,150,0), 
		*
from DBA_Admin.dbo.resource_consumption rc
where rc.event_time >= dateadd(day,-1,getdate())
and rc.database_name = 'MSAJAG'
and rc.sql_text like '%CLIENT_BROK_DETAILS%'
and result = 'OK'
--order by logical_reads desc
*/


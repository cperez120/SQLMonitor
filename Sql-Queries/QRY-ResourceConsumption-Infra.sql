use DBA_Admin
go

declare @start_time datetime = dateadd(day,-7,getdate())
declare @end_time datetime = getdate()

if object_id('tempdb..#queries') is not null drop table #queries;
;with cte_group as (
	select	[grouping-key] = (case when client_app_name like 'SQL Job = %' then client_app_name else left(DBA_Admin.dbo.normalized_sql_text(sql_text,150,0),30) end), 
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
	from DBA_Admin.dbo.resource_consumption rc
	where rc.event_time between @start_time and @end_time
	and rc.database_name = 'MSAJAG'
	and rc.sql_text like '%CLIENT_BROK_DETAILS%'
	and result = 'OK'
	group by (case when client_app_name like 'SQL Job = %' then client_app_name else left(DBA_Admin.dbo.normalized_sql_text(sql_text,150,0),30) end)
)
select *
into #queries
from cte_group ct
--order by [logical_reads_gb] desc
--select *
--from dbo.resource_consumption rc
--where (	rc.start_time between @start_time and @end_time or rc.event_time between @start_time and @end_time )
--order by writes_gb desc,  writes_mb_avg desc;
go

declare @start_time datetime = dateadd(day,-7,getdate())
declare @end_time datetime = getdate()

select top 200 rc.sql_text, q.*, rc.*
from #queries q
outer apply (select top 1 * from dbo.resource_consumption rc 
			where rc.event_time between @start_time and @end_time
			and rc.database_name = 'MSAJAG'
			and rc.sql_text like '%CLIENT_BROK_DETAILS%'
			and result = 'OK'
			and q.[grouping-key] = (case when rc.client_app_name like 'SQL Job = %' then rc.client_app_name else left(DBA_Admin.dbo.normalized_sql_text(rc.sql_text,150,0),30) end)
			--order by rc.logical_reads desc
			) rc
--where [grouping-key] not like '(dba) %'
--order by [logical_reads_mb] desc
order by [counts] desc

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


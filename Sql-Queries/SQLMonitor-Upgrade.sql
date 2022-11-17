select distinct sql_instance, [database], collector_powershell_jobs_server, sqlmonitor_version,
		count(*)over(partition by collector_powershell_jobs_server) as server_counts
from dbo.instance_details id
where 1=1
and sqlmonitor_version <> '1.1.5'
order by server_counts asc, id.collector_powershell_jobs_server, sql_instance

select *
from dbo.instance_details id
where id.sql_instance <> id.collector_tsql_jobs_server

/*
select *
-- update id set sqlmonitor_version = '1.1.5'
from dbo.instance_details id
where sql_instance = 'SomeInstance'
*/

/*
update pt set retention_days = case when pt.table_name = 'dbo.resource_consumption' then 30 else 90 end
from dbo.purge_table pt
where pt.table_name in ('dbo.BlitzIndex','dbo.disk_space','dbo.resource_consumption')
*/
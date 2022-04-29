use DBA
go

select 'instance_hosts', * from dbo.instance_hosts
go

--insert dbo.instance_hosts
--select 'SQLDR-B'

select 'instance_details', * from dbo.instance_details
go
--update dbo.instance_details set collector_sql_instance = 'SQL2019'

--insert dbo.instance_details ([sql_instance],[host_name],[collector_sql_instance])
--select i.sql_instance, h.host_name, 'SQL2019' as [collector_sql_instance]
--from dbo.instance_hosts h, (values ('SQL2019'),('SQL2017'),('SQL2016'),('SQL2014'),('SQL2012') ) i(sql_instance)
----from dbo.instance_hosts h, (values ('SQL2017') ) i(sql_instance)


select top 3 'performance_counters', * from [dbo].[performance_counters]
go

select top 3 'vw_performance_counters]', * from [dbo].[vw_performance_counters]
go

select top 3 'vw_os_task_list', * from dbo.vw_os_task_list;

--select count(*) as counts
--from [dbo].[os_task_list] otl
--where collection_time_utc = (select max(i.collection_time_utc) from [dbo].[os_task_list] i)

select *
from dbo.performance_counters pc
where pc.collection_time_utc between '2022-03-30 02:29:00.0000000' and '2022-03-30 02:31:00.0000000'
--and pc.object in ('processor') -- ,'process','processor information')
and pc.counter in ('% processor time') --and pc.instance = '_total'
order by pc.value desc

select * from sys.dm_os_schedulers dos where status = 'VISIBLE ONLINE'
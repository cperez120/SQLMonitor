create view dbo.vw_performance_counters
with schemabinding
as
with cte_counters_local as (select collection_time_utc, host_name, path, object, counter, value, instance from dbo.performance_counters)
--,cte_counters_sqlinstance2 as (select collection_time_utc, host_name, path, object, counter, value, instance from dbo.performance_counters)

select collection_time_utc, host_name, path, object, counter, value, instance from cte_counters_local
--union
--select collection_time_utc, host_name, path, object, counter, value, instance from cte_counters_sqlinstance2

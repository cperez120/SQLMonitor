use DBA_Admin
go

/* 1. Dashboard exposing tables with delta rows = 0 in last x days */
select top 100 --*
		[database_name], [schema_name], [table_name]
		,total_rows_max = max(total_rows)
		,total_rows_min = min(total_rows)
		,total_rows_avg = avg(total_rows)
		,days_count = datediff(day,min(run_datetime),max(run_datetime))
		,total_reserved_GB = max(convert(numeric(20,2),bi.total_reserved_MB/1024.0))
from dbo.BlitzIndex bi
where bi.run_datetime >= dateadd(day,-90,getdate())
and index_id <= 1
group by [database_name], [schema_name], [table_name]
having min(total_rows) = max(total_rows)
	and datediff(day,min(run_datetime),max(run_datetime)) > 7
order by total_reserved_GB desc, total_rows_max desc

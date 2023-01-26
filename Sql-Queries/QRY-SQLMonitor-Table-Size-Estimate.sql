select pt.table_name, pt.retention_days, bi.index_size_summary, bi.data_compression_desc
from dbo.BlitzIndex bi join dbo.purge_table pt 
	on pt.table_name = 'dbo.'+bi.table_name
where bi.run_datetime = (select max(run_datetime) from dbo.BlitzIndex i)
and bi.database_name = 'DBA_Admin'
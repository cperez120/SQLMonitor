use DBA_Admin
go

declare @start_time_utc datetime2 = dateadd(hour,-2,getutcdate());
declare @end_time_utc datetime2 = getutcdate();

if object_id('tempdb..#file_io_stats') is not null
	drop table #file_io_stats;
select	fis.[collection_time_utc],
		fis.[database_name],
		[files_count] = count(*),
		[num_of_bytes_read_written] = sum(fis.num_of_bytes_read + fis.num_of_bytes_written)
into #file_io_stats
from dbo.file_io_stats fis
where fis.collection_time_utc between @start_time_utc and @end_time_utc
group by fis.[collection_time_utc], fis.[database_name]

select	fis.collection_time_utc, fis.database_name, [files_count],
		fis.[num_of_bytes_read_written],
		[num_of_bytes_read_written_previous] = lag([num_of_bytes_read_written]) over (order by fis.collection_time_utc, fis.database_name)
from #file_io_stats fis
order by fis.collection_time_utc, fis.database_name
go
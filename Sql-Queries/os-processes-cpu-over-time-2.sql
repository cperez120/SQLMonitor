use DBA
go

set nocount on;

declare @start_time datetime = dateadd(minute,-60,getutcdate());
declare @end_time datetime = getutcdate();
declare @host_name nvarchar(255) = 'WORKSTATION'
declare @TopRowFilter tinyint = 10;


declare @delta_minutes int;
declare @_duration_minute int = datediff(minute,@start_time,@end_time);
set @delta_minutes = (case when @_duration_minute <= 30 then 5 when @_duration_minute <= 120 then 10 else 15 end);

if object_id('tempdb..#dates') is not null
	drop table #dates;
create table #dates (collection_time_utc datetime2 not null primary key);
declare @_collection_time_utc datetime2;
declare @_collection_time_utc_prev datetime2;

declare cur_dates cursor local fast_forward for
	select collection_time_utc
	from dbo.os_task_list 
	where host_name = @host_name
	and collection_time_utc between @start_time and @end_time
	group by collection_time_utc
	order by collection_time_utc;

open cur_dates;
fetch next from cur_dates into @_collection_time_utc;

while @@fetch_status = 0
begin
	-- Set start timestamp
	if(@_collection_time_utc_prev is null)
	begin
		insert #dates values (@_collection_time_utc);
		set @_collection_time_utc_prev = @_collection_time_utc;
	end
	
	-- Choose next timestamp based on @delta_minutes
	if (@_collection_time_utc_prev is not null)
		and (@_collection_time_utc >= dateadd(minute,@delta_minutes,@_collection_time_utc_prev))
	begin
		insert #dates values (@_collection_time_utc);
		set @_collection_time_utc_prev = @_collection_time_utc;
	end
	
	fetch next from cur_dates into @_collection_time_utc;
end

close cur_dates;
deallocate cur_dates;

--select *
--from #dates;

if object_id('tempdb..#os_task_list') is not null
	drop table #os_task_list;
with cte_tasks as (
	select tl.collection_time_utc, tl.task_name, [cpu_s] = sum(cpu_time_seconds), [counts] = count(*)
	from dbo.os_task_list tl join #dates d on d.collection_time_utc = tl.collection_time_utc
	where (tl.collection_time_utc between @start_time and @end_time)
	and tl.host_name = @host_name
	and task_name not in ('System Idle Process','') -- add other harmless processes here
	group by tl.collection_time_utc, tl.task_name
)
select	collection_time_utc, task_name, cpu_s, counts
		,[cpu_s__delta] = isnull(cpu_s - (lag(cpu_s) over (partition by task_name order by collection_time_utc)),0)
		,[CpuRank] = ROW_NUMBER() OVER(PARTITION BY [collection_time_utc] ORDER BY cpu_s DESC)
into #os_task_list
from cte_tasks;


select collection_time_utc, task_name, [cpu_s__delta]
from #os_task_list
where CpuRank <= @TopRowFilter
order by collection_time_utc, CpuRank, cpu_s desc;

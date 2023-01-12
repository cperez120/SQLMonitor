declare @_latency_minutes_threshold int = 20;
declare @_latency_days_threshold int = 3;

select cli.srv_name, cli.performance_counters__latency_minutes, cli.resource_consumption__latency_minutes,
		cli.WhoIsActive__latency_minutes, cli.os_task_list__latency_minutes, cli.disk_space__latency_minutes, 
		cli.file_io_stats__latency_minutes, cli.wait_stats__latency_minutes, cli.BlitzIndex__latency_days,
		cli.BlitzIndex_Mode0__latency_days, cli.BlitzIndex_Mode1__latency_days, cli.BlitzIndex_Mode4__latency_days,
		collection_time = DATEADD(mi, DATEDIFF(mi, getdate(), getutcdate()), cli.collection_time)
		--,cli.host_name ,si.major_version_number ,si.product_version ,si.edition, vi.os_cpu, vi.sql_cpu
from dbo.all_server_collection_latency_info cli
join dbo.all_server_stable_info si on si.srv_name = cli.srv_name
join dbo.all_server_volatile_info vi on vi.srv_name = cli.srv_name
where 1=1
and (	cli.performance_counters__latency_minutes > @_latency_minutes_threshold
		or (cli.resource_consumption__latency_minutes > @_latency_minutes_threshold*2 and vi.sql_cpu > 20 and si.major_version_number >= 11)
		or (cli.WhoIsActive__latency_minutes > @_latency_minutes_threshold*2 and vi.sql_cpu > 20)
		or cli.os_task_list__latency_minutes > @_latency_minutes_threshold
		or cli.disk_space__latency_minutes > @_latency_minutes_threshold*3
		or cli.file_io_stats__latency_minutes > @_latency_minutes_threshold*3
		or cli.wait_stats__latency_minutes > @_latency_minutes_threshold*2
		or cli.BlitzIndex__latency_days > @_latency_days_threshold
		or cli.BlitzIndex_Mode0__latency_days > @_latency_days_threshold*4
		or cli.BlitzIndex_Mode1__latency_days > @_latency_days_threshold*4
		or cli.BlitzIndex_Mode4__latency_days > @_latency_days_threshold*4
	)
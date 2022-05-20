if object_id('tempdb..#AllServerInfoResults') is not null
	drop table #AllServerInfoResults;

create table #AllServerInfoResults 
(	srv_name varchar(125), domain varchar(125), [host_name] varchar(125), product_version varchar(30), major_version_number smallint, 
	minor_version_number smallint, cpu_count smallint, scheduler_count smallint, total_physical_memory_kb bigint,
	os_start_time_utc datetime2, sqlserver_start_time_utc datetime2	
	/* os_cpu decimal(20,2), sql_cpu decimal(20,2), pcnt_kernel_mode decimal(20,2),
	page_faults_kb decimal(20,2), blocked_counts int, blocked_duration_max_seconds bigint, 
	available_physical_memory_kb bigint, system_high_memory_signal_state varchar(20), physical_memory_in_use_kb decimal(20,2),
	memory_grants_pending int, connection_count int, active_requests_count int, waits_per_core_per_minute decimal(20,2),
	*/
);

exec dbo.usp_GetAllServerInfo 
				@servers = 'SQLMONITOR,SqlPractice,Workstation' 
				,@output = 'srv_name, domain, host_name, product_version, major_version_number, minor_version_number, cpu_count, scheduler_count, 
								total_physical_memory_kb, os_start_time_utc, sqlserver_start_time_utc'
				,@result_to_table = '#AllServerInfoResults';

;with t_cte as (
	select	*
			,Concat
			(
				RIGHT('000'+CAST(ISNULL((datediff(second,os_start_time_utc,GETUTCDATE()) / 3600 / 24), 0) AS VARCHAR(3)),3)
				,' '
				,RIGHT('00'+CAST(ISNULL(datediff(second,os_start_time_utc,GETUTCDATE()) / 3600  % 24, 0) AS VARCHAR(2)),2)
				,':'
				,RIGHT('00'+CAST(ISNULL(datediff(second,os_start_time_utc,GETUTCDATE()) / 60 % 60, 0) AS VARCHAR(2)),2)
				,':'
				,RIGHT('00'+CAST(ISNULL(datediff(second,os_start_time_utc,GETUTCDATE()) % 3600 % 60, 0) AS VARCHAR(2)),2)
			) as [os_uptime]
			,Concat
			(
				RIGHT('000'+CAST(ISNULL((datediff(second,sqlserver_start_time_utc,GETUTCDATE()) / 3600 / 24), 0) AS VARCHAR(3)),3)
				,' '
				,RIGHT('00'+CAST(ISNULL(datediff(second,sqlserver_start_time_utc,GETUTCDATE()) / 3600  % 24, 0) AS VARCHAR(2)),2)
				,':'
				,RIGHT('00'+CAST(ISNULL(datediff(second,sqlserver_start_time_utc,GETUTCDATE()) / 60 % 60, 0) AS VARCHAR(2)),2)
				,':'
				,RIGHT('00'+CAST(ISNULL(datediff(second,sqlserver_start_time_utc,GETUTCDATE()) % 3600 % 60, 0) AS VARCHAR(2)),2)
			) as [sqlserver_uptime]
			,datediff(day,os_start_time_utc,GETUTCDATE()) as [os_uptime_days]
	from #AllServerInfoResults
)
select  srv_name, domain, host_name, product_version, major_version_number, minor_version_number
        ,[CPU (OS / SQL)] = convert(varchar,cpu_count)+' / '+convert(varchar,scheduler_count)
        ,total_physical_memory_kb ,cpu_count, scheduler_count, [os_uptime_days], os_start_time_utc, sqlserver_start_time_utc, [os_uptime], [sqlserver_uptime]
		    ,[Is MS Supported] = case when c.MainstreamSupportEndDate < getdate() then convert(bit,0) else convert(bit,1) end
from t_cte cte
outer apply (
	select	top 1 [MajorVersionNumber]
				--,[@server_minor_version_number] = @server_minor_version_number
				,[MinorVersionNumber]
				,[Branch]
				,[Url]
				,[ReleaseDate]
				,[MainstreamSupportEndDate]
				,[ExtendedSupportEndDate]
				,[MajorVersionName]
				,[MinorVersionName]	  
		from [master].[dbo].[SqlServerVersions] as c
		where [MajorVersionNumber] = cte.major_version_number
		and [MinorVersionNumber] <= cte.minor_version_number
		order by [MinorVersionNumber] desc
) as c
outer apply (
	select	top 1 [MajorVersionNumber]
			--,[@server_minor_version_number] = @server_minor_version_number
			,[MinorVersionNumber]
			,[Branch]
			,[Url]
			,[ReleaseDate]
			,[MainstreamSupportEndDate]
			,[ExtendedSupportEndDate]
			,[MajorVersionName]
			,[MinorVersionName]	  
	from [master].[dbo].[SqlServerVersions] as c
	where [MajorVersionNumber] = cte.major_version_number
	order by [MinorVersionNumber] desc
) as l

--if object_id('tempdb..##AllServerInfoResults') is not null
--	drop table ##AllServerInfoResults;
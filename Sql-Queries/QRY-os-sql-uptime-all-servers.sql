if object_id('tempdb..##AllServerInfoResults') is not null
	drop table ##AllServerInfoResults;

exec dbo.usp_GetAllServerInfo 
				@servers = 'SQLMONITOR,SqlPractice,Workstation' 
				,@output = 'srv_name, domain, host_name, product_version, major_version_number, minor_version_number, cpu_count, scheduler_count,os_start_time_utc, sqlserver_start_time_utc'
				,@result_to_table = '##AllServerInfoResults';

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
	from ##AllServerInfoResults
)
select srv_name, domain, host_name, product_version, major_version_number, minor_version_number, cpu_count, scheduler_count, [os_uptime_days], os_start_time_utc, sqlserver_start_time_utc, [os_uptime], [sqlserver_uptime]
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

if object_id('tempdb..##AllServerInfoResults') is not null
	drop table ##AllServerInfoResults;
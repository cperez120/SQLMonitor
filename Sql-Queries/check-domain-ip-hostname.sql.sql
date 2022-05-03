USE DBA
GO

select	default_domain() as [domain], 
		[ip] = CONNECTIONPROPERTY('local_net_address'), 
		[sql_instance] = serverproperty('MachineName'),
		[server_name] = serverproperty('ServerName'),
		[host_name] = SERVERPROPERTY('ComputerNamePhysicalNetBIOS'),
		[sql_version] = @@VERSION, 
		[service_name_str] = servicename,
		[service_name] = case when @@servicename = 'MSSQLSERVER' then @@servicename else 'MSSQL$'+@@servicename end,
		[instance_name] = @@servicename,
		service_account,
		SERVERPROPERTY('Edition') AS Edition,
		SERVERPROPERTY('ProductVersion') AS ProductVersion,  
		SERVERPROPERTY('ProductLevel') AS ProductLevel  
		--,instant_file_initialization_enabled
		--,*
from sys.dm_server_services where servicename like 'SQL Server (%)'

select *
from sys.dm_os_cluster_nodes;


DECLARE @Domain NVARCHAR(100)
EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE', 'SYSTEM\CurrentControlSet\services\Tcpip\Parameters', N'Domain',@Domain OUTPUT;     
SELECT Cast(SERVERPROPERTY('MachineName') as nvarchar) + '.' + @Domain AS FQDN
GO

select * from dbo.instance_details with (nolock);
go

select top 1 'vw_performance_counters' as QueryData, getutcdate() as current_time_utc, collection_time_utc, pc.host_name
from dbo.vw_performance_counters pc with (nolock)
order by pc.collection_time_utc desc
go

select top 1 'vw_os_task_list' as QueryData, getutcdate() as current_time_utc, collection_time_utc, pc.host_name
from dbo.vw_os_task_list pc with (nolock)
order by pc.collection_time_utc desc
go

-- update statistics dbo.performance_counters with sample 5 percent, all
-- update statistics dbo.performance_counters with fullscan

/*
declare @login nvarchar(125) = suser_name();
exec sp_WhoIsActive @filter_type = 'login', @filter = @login, @get_plans = 2

--performance_counters
*/
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
		,instant_file_initialization_enabled
		,*
from sys.dm_server_services

select *
from sys.dm_os_cluster_nodes;


DECLARE @Domain NVARCHAR(100)
EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE', 'SYSTEM\CurrentControlSet\services\Tcpip\Parameters', N'Domain',@Domain OUTPUT;     
SELECT Cast(SERVERPROPERTY('MachineName') as nvarchar) + '.' + @Domain AS FQDN


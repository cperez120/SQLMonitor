
CREATE PROCEDURE dbo.usp_GetAllServerInfo
	WITH RECOMPILE, EXECUTE AS OWNER AS 
BEGIN

	/*
		Version:		1.0.0
		Date:			2022-05-16

		exec dbo.usp_GetAllServerInfo
		https://stackoverflow.com/questions/10191193/how-to-test-linkedservers-connectivity-in-tsql
	*/
	SET NOCOUNT ON; 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET LOCK_TIMEOUT 60000; -- 60 seconds 

	  
	/*
	select  $server as [Sql Instance]
			,'$ip' as [IP]
			,'$domain' as [Domain]
			,'$host_name' as [Host Name]
			,'$product_version' as [Version]
			,datediff(minute,'${sqlserver_start_time_utc:date}',sysutcdatetime()) as [Up Time (Min)]
			,$ring_buffer_os_cpu as [OS CPU]
			,$ring_buffer_sql_cpu as [SQL CPU]
			,$ring_buffer_pcnt_kernel_mode as [% Kernel Mode]
			,$ring_buffer_page_faults_kb as [Page Faults (KB)]
			,$blocked_counts as [Blocked Sessions]
			,$blocked_duration_max_seconds as [Blocking Time (Sec)]
			,$total_physical_memory_kb as [Memory (KB)]
			,$available_physical_memory_kb as [Available Memory (KB)]
			,$system_high_memory_signal_state as [High Memory State]
			,$physical_memory_in_use_kb as [Sql Memory (KB)]
			,$memory_grants_pending as [Memory Grants Pending]
			,$connection_count as [Connections]
			,$active_requests_count as [Active Requests]
			,$waits_per_core_per_minute as [Waits_S Per Core Per Minute]
	*/


END

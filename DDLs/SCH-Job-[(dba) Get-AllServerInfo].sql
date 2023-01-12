USE [msdb]
GO

if exists (select * from msdb.dbo.sysjobs_view where name = N'(dba) Get-AllServerInfo')
	EXEC msdb.dbo.sp_delete_job @job_name=N'(dba) Get-AllServerInfo', @delete_unused_schedule=1
GO

USE [msdb]
GO


BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'(dba) SQLMonitor' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'(dba) SQLMonitor'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'(dba) Get-AllServerInfo', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job execute procedure usp_GetAllServerInfo and populates in table dbo.all_server_info

https://ajaydwivedi.com/github/sqlmonitor', 
		@category_name=N'(dba) SQLMonitor', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'dbo.all_server_stable_info', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- Stable Info
if	( (select count(1) from dbo.all_server_stable_info) <> (select count(distinct sql_instance) from dbo.instance_details) )
	or ( (select max(collection_time) from  dbo.all_server_stable_info) < dateadd(minute, -30, SYSDATETIME()) )
begin
	exec dbo.usp_GetAllServerInfo @result_to_table = ''dbo.all_server_stable_info'',
				@output = ''srv_name, at_server_name, machine_name, server_name, ip, domain, host_name, product_version, edition, sqlserver_start_time_utc, total_physical_memory_kb, os_start_time_utc, cpu_count, scheduler_count, major_version_number, minor_version_number'';
end', 
		@database_name=N'DBA', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'dbo.all_server_volatile_info', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- Volatile Info
exec dbo.usp_GetAllServerInfo @result_to_table = ''dbo.all_server_volatile_info'',
			@output = ''srv_name, os_cpu, sql_cpu, pcnt_kernel_mode, page_faults_kb, blocked_counts, blocked_duration_max_seconds, available_physical_memory_kb, system_high_memory_signal_state, physical_memory_in_use_kb, memory_grants_pending, connection_count, active_requests_count, waits_per_core_per_minute'';', 
		@database_name=N'DBA', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'dbo.all_server_collection_latency_info', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- Fetch Collection Info
if not exists (select 1/0 from dbo.all_server_collection_latency_info where collection_time >= dateadd(minute,-15,getdate()))
begin
	exec dbo.usp_GetAllServerInfo @result_to_table = ''dbo.all_server_collection_latency_info'',
				@output = ''srv_name, host_name, performance_counters__latency_minutes, resource_consumption__latency_minutes, WhoIsActive__latency_minutes, os_task_list__latency_minutes, disk_space__latency_minutes, file_io_stats__latency_minutes, wait_stats__latency_minutes, BlitzIndex__latency_days, BlitzIndex_Mode0__latency_days, BlitzIndex_Mode1__latency_days, BlitzIndex_Mode4__latency_days'';
end', 
		@database_name=N'DBA', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'dbo.usp_populate__all_server_volatile_info_history', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- Populate dbo.all_server_volatile_info_history
exec dbo.usp_populate__all_server_volatile_info_history', 
		@database_name=N'DBA', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1

IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'(dba) Get-AllServerInfo', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=20, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20220715, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959
		--,@schedule_uid=N'8dc38708-8287-427d-9f7c-fec4aac2ea02'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

EXEC msdb.dbo.sp_start_job @job_name=N'(dba) Get-AllServerInfo'
go
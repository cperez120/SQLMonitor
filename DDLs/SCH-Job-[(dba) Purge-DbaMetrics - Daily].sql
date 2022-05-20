USE [msdb]
GO

/****** Object:  Job [(dba) Purge-DbaMetrics - Daily]    Script Date: Tue, 19 Apr 12:33:20 ******/
if exists (select * from msdb.dbo.sysjobs_view where name = N'(dba) Purge-DbaMetrics - Daily')
	EXEC msdb.dbo.sp_delete_job @job_name=N'(dba) Purge-DbaMetrics - Daily', @delete_unused_schedule=1
GO


/****** Object:  Job [(dba) Purge-DbaMetrics - Daily]    Script Date: 5/9/2022 11:44:39 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [(dba) Monitoring & Alerting]    Script Date: 5/9/2022 11:44:39 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'(dba) Monitoring & Alerting' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'(dba) Monitoring & Alerting'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'(dba) Purge-DbaMetrics - Daily', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Cleanup tables -

dbo.performance_counters
dbo.perfmon_files', 
		@category_name=N'(dba) Monitoring & Alerting', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [dbo.performance_counters]    Script Date: 5/9/2022 11:44:39 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'dbo.performance_counters', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @r INT;
	
SET @r = 1;
while @r > 0
begin
	delete top (100000) pc
	from dbo.performance_counters pc
	where pc.collection_time_utc < dateadd(day,-30,sysutcdatetime())
	--option (table hint(h, INDEX(ci_alwayson_synchronization_history_aggregated)))

	set @r = @@ROWCOUNT
end', 
		@database_name=N'DBA', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [dbo.perfmon_files]    Script Date: 5/9/2022 11:44:39 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'dbo.perfmon_files', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @r INT;
	
SET @r = 1;
while @r > 0
begin
	delete top (100000) pf
	from dbo.perfmon_files pf
	where pf.collection_time_utc < dateadd(day,-10,sysutcdatetime())
	--option (table hint(h, INDEX(ci_alwayson_synchronization_history_aggregated)))

	set @r = @@ROWCOUNT
end', 
		@database_name=N'DBA', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [dbo.os_task_list]    Script Date: 5/9/2022 11:44:39 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'dbo.os_task_list', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @r INT;
	
SET @r = 1;
while @r > 0
begin
	delete top (100000) otl
	from dbo.os_task_list otl
	where otl.collection_time_utc < dateadd(day,-90,sysutcdatetime())

	set @r = @@ROWCOUNT
end', 
		@database_name=N'DBA', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [dbo.wait_stats]    Script Date: 5/9/2022 11:44:39 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'dbo.wait_stats', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @r INT;
	
SET @r = 1;
while @r > 0
begin
	delete top (100000) ws
	from dbo.wait_stats ws
	where collection_time_utc < dateadd(day,-90,sysutcdatetime())
	--option (table hint(h, INDEX(ci_alwayson_synchronization_history_aggregated)))

	set @r = @@ROWCOUNT
end', 
		@database_name=N'DBA', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [dbo.resource_consumption]    Script Date: 5/9/2022 11:44:39 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'dbo.resource_consumption', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @r INT;
	
SET @r = 1;
while @r > 0
begin
	delete top (100000) pf
	from dbo.resource_consumption pf
	where pf.event_time < dateadd(day,-90,sysdatetime())
	--option (table hint(h, INDEX(ci_alwayson_synchronization_history_aggregated)))

	set @r = @@ROWCOUNT
end
', 
		@database_name=N'DBA', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [dbo.resource_consumption_Processed_XEL_Files]    Script Date: 5/9/2022 11:44:39 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'dbo.resource_consumption_Processed_XEL_Files', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @r INT;
	
SET @r = 1;
while @r > 0
begin
	delete top (100000) pf
	from dbo.resource_consumption_Processed_XEL_Files pf
	where pf.collection_time_utc < dateadd(day,-7,sysutcdatetime())
	--option (table hint(h, INDEX(ci_alwayson_synchronization_history_aggregated)))

	set @r = @@ROWCOUNT
end
', 
		@database_name=N'DBA', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'(dba) Purge-DbaMetrics - Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=24, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20220326, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959
		--,@schedule_uid=N'88003296-9d27-4a85-b0d8-56dd53fcd928'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


EXEC msdb.dbo.sp_start_job @job_name=N'(dba) Purge-DbaMetrics - Daily'
GO

USE [msdb]
GO

/****** Object:  Job [(dba) Run First-Responder-Kit]    Script Date: Tue, 19 Apr 12:33:50 ******/
if exists (select * from msdb.dbo.sysjobs_view where name = N'(dba) Run First-Responder-Kit')
	EXEC msdb.dbo.sp_delete_job @job_name=N'(dba) Run First-Responder-Kit', @delete_unused_schedule=1
GO

USE [msdb]
GO

/****** Object:  Job [(dba) Run First-Responder-Kit]    Script Date: 4/22/2022 10:51:38 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [(dba) Monitoring & Alerting]    Script Date: 4/22/2022 10:51:38 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'(dba) Monitoring & Alerting' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'(dba) Monitoring & Alerting'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'(dba) Run First-Responder-Kit', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Caputure stats using sp_BlitzFirst', 
		@category_name=N'(dba) Monitoring & Alerting', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [(dba) Run First-Responder-Kit]    Script Date: 4/22/2022 10:51:38 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'(dba) Run First-Responder-Kit', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @db_name sysname = db_name();


exec sp_BlitzFirst
	@OutputDatabaseName = @db_name,
	@OutputSchemaName = ''dbo'',
	@OutputTableName = ''BlitzFirst'',
	@OutputTableNameFileStats = ''BlitzFirst_FileStats'',
	--@OutputTableNamePerfmonStats = ''BlitzFirst_PerfmonStats'',
	--@OutputTableNameWaitStats = ''BlitzFirst_WaitStats'',
	@OutputTableNameBlitzCache = ''BlitzCache'',
	@OutputTableNameBlitzWho = ''BlitzWho'',
	@OutputTableRetentionDays = 30', 
		@database_name=N'DBA', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'(dba) Run First-Responder-Kit - WaitStats', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20220318, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'fcd79fa8-3d9d-4b30-88d0-9a14081e3339'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


USE [msdb]
GO

if exists (select * from msdb.dbo.sysjobs_view where name = N'(dba) Run-BlitzIndex')
	EXEC msdb.dbo.sp_delete_job @job_name=N'(dba) Run-BlitzIndex', @delete_unused_schedule=1
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
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'(dba) Run-BlitzIndex', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Capture index usage details into SQL Table .', 
		@category_name=N'(dba) SQLMonitor', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'sp_BlitzIndex @Mode = 2', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'sqlcmd -E -b -S localhost -d DBA -Q "EXEC master.dbo.sp_BlitzIndex @GetAllDatabases = 1, @Mode = 2, @BringThePain = 1, @OutputDatabaseName = ''DBA'', @OutputSchemaName = ''dbo'', @OutputTableName = ''BlitzIndex'';"', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'(dba) Run-BlitzIndex', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20221002, 
		@active_end_date=99991231, 
		@active_start_time=190000, 
		@active_end_time=235959
		--,@schedule_uid=N'cc775d0e-ad80-4318-8894-c58fedcdabb4'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

EXEC master.dbo.sp_BlitzIndex @DatabaseName = 'master', @Mode = 2, @BringThePain = 1, 
			@OutputDatabaseName = 'DBA', @OutputSchemaName = 'dbo', @OutputTableName = 'BlitzIndex';
GO

EXEC msdb.dbo.sp_start_job @job_name=N'(dba) Run-BlitzIndex'
go




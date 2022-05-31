USE [msdb]
GO

if exists (select * from msdb.dbo.sysjobs_view where name = N'(dba) Purge-Tables')
	EXEC msdb.dbo.sp_delete_job @job_name=N'(dba) Purge-Tables', @delete_unused_schedule=1
GO

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'(dba) Monitoring & Alerting' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'(dba) Monitoring & Alerting'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'(dba) Purge-Tables', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job delete data from all the tables mentioned in DBA.dbo.purge_table', 
		@category_name=N'(dba) Monitoring & Alerting', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'dbo.purge_table', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @c_table_name sysname;
declare @c_date_key sysname;
declare @c_retention_days smallint;
declare @c_purge_row_size int;
declare @sql nvarchar(max);
declare @err_message nvarchar(2000);

declare cur_purge_tables cursor local forward_only for
	select table_name, date_key, retention_days, purge_row_size from dbo.purge_table;

open cur_purge_tables;
fetch next from cur_purge_tables into @c_table_name, @c_date_key, @c_retention_days, @c_purge_row_size;

while @@FETCH_STATUS = 0
begin
	print ''Processing table ''+@c_table_name;

	set @sql = ''
	DECLARE @r INT;
	
	SET @r = 1;
	while @r > 0
	begin
		delete top (''+convert(varchar,@c_purge_row_size)+'') pt
		from ''+@c_table_name+'' pt
		where ''+@c_date_key+'' < dateadd(day,-''+convert(varchar,@c_retention_days)+'',cast(getdate() as date));

		set @r = @@ROWCOUNT;
	end
	''
	begin try
		exec (@sql);
		update dbo.purge_table set latest_purge_datetime = SYSDATETIME() where table_name = @c_table_name;
	end try
	begin catch
		set @err_message = isnull(@err_message,'''') + char(10) + ''Error while purging table ''+@c_table_name+''.''+char(10)+ ERROR_MESSAGE()+char(10);
	end catch
	fetch next from cur_purge_tables into @c_table_name, @c_date_key, @c_retention_days, @c_purge_row_size;
end
close cur_purge_tables;
deallocate cur_purge_tables;

if @err_message is not null
	throw 50000, @err_message, 1;', 
		@database_name=N'DBA', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'(dba) Purge-Tables', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20220601, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959 
		--,@schedule_uid=N'0f78628a-e7fe-40cd-9df1-6d2805dfcdcf'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


if exists (select * from msdb.dbo.sysjobs_view where name = N'(dba) Purge-Tables')
	EXEC msdb.dbo.sp_start_job @job_name=N'(dba) Purge-Tables'
GO
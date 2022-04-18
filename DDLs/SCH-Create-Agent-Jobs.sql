/* ***********************************************************
** ********** Find & Replace below texts *********************
** -------------------------------------------------------- **
1) Find "@database_name=N'DBA'", and replace database Name
2) Find "@notify_email_operator_name=N'SQLAgentService'", and replace Operator
3) Create Job Category [(dba) Monitoring & Alerting]

**************************************************************
* ********** JOBS Being Created ******************************
* ---------------------------------------------------------- *
1) [(dba) Collect-PerfmonData]
2) [(dba) Partitions-Maintenance]
3) [(dba) Purge-DbaMetrics - Daily]
*/

USE [msdb]
GO

/****** Object:  Job [(dba) Collect-PerfmonData]    Script Date: Mon, 18 Apr 16:19:20 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [(dba) Monitoring & Alerting]    Script Date: Mon, 18 Apr 16:19:20 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'(dba) Monitoring & Alerting' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'(dba) Monitoring & Alerting'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'(dba) Collect-PerfmonData', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job captures Perfmon data as per template 

https://github.com/imajaydwivedi/SqlServer-Baselining-Grafana/blob/master/NonSql-Files/DBA_PerfMon_All_Counters_Template.xml', 
		@category_name=N'(dba) Monitoring & Alerting', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Import-PerfmonData]    Script Date: Mon, 18 Apr 16:19:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Import-PerfmonData', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'powershell.exe -executionpolicy bypass -Noninteractive  D:\GitHub-Personal\SqlServer-Baselining-Grafana\NonSql-Files\perfmon-collector-push-to-sqlserver.ps1 -SqlInstance ''localhost'' -Database ''DBA''', 
		@flags=40, 
		@proxy_name=N'Ajay'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Import-TaskList]    Script Date: Mon, 18 Apr 16:19:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Import-TaskList', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'powershell.exe -executionpolicy bypass -Noninteractive  D:\GitHub-Personal\SqlServer-Baselining-Grafana\NonSql-Files\tasklist-push-to-sqlserver.ps1 -SqlInstance ''localhost'' -Database ''DBA''', 
		@flags=40, 
		@proxy_name=N'Ajay'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'(dba) Collect-PerfmonData - Every 30 Seconds', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=60, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20220326, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'e7418cb1-0f4e-4a22-8c57-240817bf6c5d'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [(dba) Partitions-Maintenance]    Script Date: Mon, 18 Apr 16:19:21 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [(dba) Monitoring & Alerting]    Script Date: Mon, 18 Apr 16:19:21 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'(dba) Monitoring & Alerting' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'(dba) Monitoring & Alerting'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'(dba) Partitions-Maintenance', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job takes care of creating new partitions and removing old partitions', 
		@category_name=N'(dba) Monitoring & Alerting', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[datetime2] - Add partitions - Hourly - Till Next Quarter End]    Script Date: Mon, 18 Apr 16:19:21 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[datetime2] - Add partitions - Hourly - Till Next Quarter End', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'set nocount on;
SET QUOTED_IDENTIFIER ON;

declare @current_boundary_value datetime2;
declare @target_boundary_value datetime2; /* last day of new quarter */
set @target_boundary_value = DATEADD (dd, -1, DATEADD(qq, DATEDIFF(qq, 0, GETDATE()) +2, 0));

select top 1 @current_boundary_value = convert(datetime2,prv.value)
from sys.partition_range_values prv
join sys.partition_functions pf on pf.function_id = prv.function_id
where pf.name = ''pf_dba''
order by prv.value desc;

select [@current_boundary_value] = @current_boundary_value, [@target_boundary_value] = @target_boundary_value;

while (@current_boundary_value < @target_boundary_value)
begin
	set @current_boundary_value = DATEADD(hour,1,@current_boundary_value);
	--print @current_boundary_value
	alter partition scheme ps_dba next used [primary];
	alter partition function pf_dba() split range (@current_boundary_value);	
end', 
		@database_name=N'DBA', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[datetime] - Add partitions - Hourly - Till Next Quarter End]    Script Date: Mon, 18 Apr 16:19:21 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[datetime] - Add partitions - Hourly - Till Next Quarter End', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'set nocount on;
SET QUOTED_IDENTIFIER ON;

declare @current_boundary_value datetime;
declare @target_boundary_value datetime; /* last day of new quarter */
set @target_boundary_value = DATEADD (dd, -1, DATEADD(qq, DATEDIFF(qq, 0, GETDATE()) +2, 0));

select top 1 @current_boundary_value = convert(datetime,prv.value)
from sys.partition_range_values prv
join sys.partition_functions pf on pf.function_id = prv.function_id
where pf.name = ''pf_dba_datetime''
order by prv.value desc;

select [@current_boundary_value] = @current_boundary_value, [@target_boundary_value] = @target_boundary_value;

while (@current_boundary_value < @target_boundary_value)
begin
	set @current_boundary_value = DATEADD(hour,1,@current_boundary_value);
	--print @current_boundary_value
	alter partition scheme ps_dba_datetime next used [primary];
	alter partition function pf_dba_datetime() split range (@current_boundary_value);	
end', 
		@database_name=N'DBA', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[datetime2] - Remove Partitions - Retain upto 3 Months]    Script Date: Mon, 18 Apr 16:19:21 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[datetime2] - Remove Partitions - Retain upto 3 Months', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'set nocount on;
SET QUOTED_IDENTIFIER ON;

declare @partition_boundary datetime2;
declare @target_boundary_value datetime2; /* 3 months back date */
set @target_boundary_value = DATEADD(mm,DATEDIFF(mm,0,GETDATE())-3,0);
--set @target_boundary_value = ''2022-03-25 19:00:00.000''

declare cur_boundaries cursor local fast_forward for
		select convert(datetime2,prv.value) as boundary_value
		from sys.partition_range_values prv
		join sys.partition_functions pf on pf.function_id = prv.function_id
		where pf.name = ''pf_dba'' and convert(datetime2,prv.value) < @target_boundary_value
		order by prv.value asc;

open cur_boundaries;
fetch next from cur_boundaries into @partition_boundary;
while @@FETCH_STATUS = 0
begin
	--print @partition_boundary
	alter partition function pf_dba() merge range (@partition_boundary);

	fetch next from cur_boundaries into @partition_boundary;
end
CLOSE cur_boundaries
DEALLOCATE cur_boundaries;', 
		@database_name=N'DBA', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [[datetime] - Remove Partitions - Retain upto 3 Months]    Script Date: Mon, 18 Apr 16:19:21 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'[datetime] - Remove Partitions - Retain upto 3 Months', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'set nocount on;
SET QUOTED_IDENTIFIER ON;

declare @partition_boundary datetime;
declare @target_boundary_value datetime; /* 3 months back date */
set @target_boundary_value = DATEADD(mm,DATEDIFF(mm,0,GETDATE())-3,0);
--set @target_boundary_value = ''2022-03-25 19:00:00.000''

declare cur_boundaries cursor local fast_forward for
		select convert(datetime,prv.value) as boundary_value
		from sys.partition_range_values prv
		join sys.partition_functions pf on pf.function_id = prv.function_id
		where pf.name = ''pf_dba_datetime'' and convert(datetime,prv.value) < @target_boundary_value
		order by prv.value asc;

open cur_boundaries;
fetch next from cur_boundaries into @partition_boundary;
while @@FETCH_STATUS = 0
begin
	--print @partition_boundary
	alter partition function pf_dba_datetime() merge range (@partition_boundary);

	fetch next from cur_boundaries into @partition_boundary;
end
CLOSE cur_boundaries
DEALLOCATE cur_boundaries;', 
		@database_name=N'DBA', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'(dba) Partitions-Maintenance - Daily', 
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
		@active_end_time=235959, 
		@schedule_uid=N'b43ab780-6b08-4127-a36f-e2f478409210'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [(dba) Purge-DbaMetrics - Daily]    Script Date: Mon, 18 Apr 16:19:21 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [(dba) Monitoring & Alerting]    Script Date: Mon, 18 Apr 16:19:21 ******/
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
/****** Object:  Step [dbo.performance_counters]    Script Date: Mon, 18 Apr 16:19:21 ******/
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
	where pc.collection_time_utc < dateadd(day,-90,sysutcdatetime())
	--option (table hint(h, INDEX(ci_alwayson_synchronization_history_aggregated)))

	set @r = @@ROWCOUNT
end', 
		@database_name=N'DBA', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [dbo.perfmon_files]    Script Date: Mon, 18 Apr 16:19:21 ******/
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
	where pf.collection_time_utc < dateadd(day,-90,sysutcdatetime())
	--option (table hint(h, INDEX(ci_alwayson_synchronization_history_aggregated)))

	set @r = @@ROWCOUNT
end', 
		@database_name=N'DBA', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [dbo.os_task_list]    Script Date: Mon, 18 Apr 16:19:21 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'dbo.os_task_list', 
		@step_id=3, 
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
	delete top (100000) otl
	from dbo.os_task_list otl
	where otl.collection_time_utc < dateadd(day,-90,sysutcdatetime())

	set @r = @@ROWCOUNT
end', 
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
		@active_end_time=235959, 
		@schedule_uid=N'88003296-9d27-4a85-b0d8-56dd53fcd928'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [(dba) Run First-Responder-Kit]    Script Date: Mon, 18 Apr 16:19:21 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [(dba) Monitoring & Alerting]    Script Date: Mon, 18 Apr 16:19:21 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'(dba) Monitoring & Alerting' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'(dba) Monitoring & Alerting'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'(dba) Run First-Responder-Kit', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Caputure stats using sp_BlitzFirst', 
		@category_name=N'(dba) Monitoring & Alerting', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [(dba) Run First-Responder-Kit]    Script Date: Mon, 18 Apr 16:19:21 ******/
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
		@command=N'exec sp_BlitzFirst
	@OutputDatabaseName = ''DBA'',
	@OutputSchemaName = ''dbo'',
	@OutputTableName = ''BlitzFirst'',
	@OutputTableNameFileStats = ''BlitzFirst_FileStats'',
	@OutputTableNamePerfmonStats = ''BlitzFirst_PerfmonStats'',
	@OutputTableNameWaitStats = ''BlitzFirst_WaitStats'',
	@OutputTableNameBlitzCache = ''BlitzCache'',
	@OutputTableNameBlitzWho = ''BlitzWho'',
	@OutputTableRetentionDays = 30', 
		@database_name=N'DBA', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'(dba) Run First-Responder-Kit', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=10, 
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

/****** Object:  Job [(dba) Run-WhoIsActive]    Script Date: Mon, 18 Apr 16:19:21 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [(dba) Monitoring & Alerting]    Script Date: Mon, 18 Apr 16:19:21 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'(dba) Monitoring & Alerting' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'(dba) Monitoring & Alerting'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'(dba) Run-WhoIsActive', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Capture sp_WhoIsActive result', 
		@category_name=N'(dba) Monitoring & Alerting', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [(dba) Run-WhoIsActive]    Script Date: Mon, 18 Apr 16:19:21 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'(dba) Run-WhoIsActive', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- USE <<Your DBA Datatabase Name Here>>

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_WARNINGS ON;

-- Parameters
DECLARE @retention_day int = 30;
DECLARE @drop_recreate bit = 0;
DECLARE	@destination_table VARCHAR(4000) = ''dbo.WhoIsActive'';
DECLARE	@staging_table VARCHAR(4000) = @destination_table+''_Staging'';
DECLARE @output_column_list VARCHAR(8000);
DECLARE @send_error_mail bit = 1;
DECLARE @threshold_continous_failure tinyint = 3;
DECLARE @notification_delay_minutes tinyint = 15;
DECLARE @is_test_alert bit = 0;
DECLARE @verbose tinyint = 0; /* 0 - no messages, 1 - debug messages, 2 = debug messages + table results */
DECLARE @recipients varchar(500) = ''sqlagentservice@gmail.com'';

/* Additional Requirements
1) Default Global Mail Profile
	-> SqlInstance -> Management -> Right click "Database Mail" -> Configure Database Mail -> Select option "Manage profile security" -> Check Public checkbox, and Select "Yes" for Default for profile that should be set a global default
2) Make sure context database is set to correct dba database
*/


SET @output_column_list = ''[collection_time][dd hh:mm:ss.mss][session_id][program_name][login_name][database_name]
						[CPU][CPU_delta][used_memory][used_memory_delta][open_tran_count][status][wait_info][sql_command]
                        [blocked_session_count][blocking_session_id][sql_text][%]'';

DECLARE @_output VARCHAR(8000);
SET @_output = ''Declare local variables''+CHAR(10);
-- Local Variables
DECLARE @_rows_affected int = 0;
DECLARE @_s NVARCHAR(MAX);
DECLARE @_collection_time datetime = GETDATE();
DECLARE @_columns VARCHAR(8000);
DECLARE @_cpu_system int;
DECLARE @_cpu_sql int;
DECLARE @_last_sent_failed_active datetime;
DECLARE @_last_sent_failed_cleared datetime;
DECLARE @_mail_body_html  NVARCHAR(MAX);  
DECLARE @_subject nvarchar(1000);
DECLARE @_job_name nvarchar(500);
DECLARE @_continous_failures tinyint = 0;
DECLARE @_send_mail bit = 0;

IF @verbose > 0
	PRINT ''Dynamically fetch @_job_name ..''
SET @_job_name = ''(dba) Run-WhoIsActive'';
IF program_name() LIKE ''SQLAgent - TSQL JobStep (Job %''
	EXEC sp_executesql	@stmt = N''SELECT @_job_name_OUTPUT = name FROM msdb.dbo.sysjobs WHERE job_id = CONVERT(uniqueidentifier, $(ESCAPE_NONE(JOBID)))'',
						@params = N''@_job_name_OUTPUT nvarchar(500) OUTPUT'',
						@_job_name_OUTPUT = @_job_name OUTPUT;
--PRINT ''"''+@_job_name+''"'';

IF @verbose > 0
BEGIN
	PRINT ''@destination_table => ''+@destination_table;
	PRINT ''@staging_table => ''+@staging_table;
END

-- Variables for Try/Catch Block
DECLARE @_profile_name varchar(200);
DECLARE	@_errorNumber int,
		@_errorSeverity int,
		@_errorState int,
		@_errorLine int,
		@_errorMessage nvarchar(4000);

BEGIN TRY
	SET @_output += ''<br>Start Try Block..''+CHAR(10);
	IF @verbose > 0
		PRINT ''Start Try Block..'';

	-- Step 01: Truncate/Create Staging table
	IF @verbose > 0
		PRINT ''Start Step 01: Truncate/Create Staging table..'';
	IF ( (OBJECT_ID(@staging_table) IS NULL) OR (@drop_recreate = 1))
	BEGIN
		SET @_output += ''<br>Inside Step 01: Create Staging table..''+CHAR(10);
		
		IF (@drop_recreate = 1)
		BEGIN
			IF @verbose > 0
				PRINT CHAR(9)+''Inside Step 01: Drop Staging table if exists..'';
			SET @_s = ''if object_id(''''''+@staging_table+'''''') is not null drop table ''+@staging_table;
			IF @verbose > 1
				PRINT CHAR(9)+@_s;
			EXEC(@_s)
		END

		IF @verbose > 0
			PRINT CHAR(9)+''Inside Step 01: Create Staging table with @output_column_list..'';
		EXEC dbo.sp_WhoIsActive @get_outer_command=1, @get_task_info=2, @find_block_leaders=1, @get_plans=1, @get_avg_time=1, @get_additional_info=1, @delta_interval = 10
				,@output_column_list = @output_column_list
				,@return_schema = 1, @schema = @_s OUTPUT; 
		SET @_s = REPLACE(@_s, ''<table_name>'', @staging_table) 
		IF @verbose > 1
			PRINT CHAR(9)+@_s;
		EXEC(@_s)
	END
	ELSE
	BEGIN
		SET @_output += ''<br>Inside Step 01: Truncate Staging table..''+CHAR(10);
		IF @verbose > 0
			PRINT CHAR(9)+''Inside Step 01: Truncate Staging table..'';
		SET @_s = ''TRUNCATE TABLE ''+@staging_table;
		IF @verbose > 1
			PRINT CHAR(9)+@_s;
		EXEC(@_s);
	END
	IF @verbose > 0
		PRINT ''End Step 01: Truncate/Create Staging table..''+char(10);
	
	-- Step 02: Create main table if Not Exists
	IF @verbose > 0
		PRINT ''Start Step 02: Create main table if Not Exists..'';
	IF ( (OBJECT_ID(@destination_table) IS NULL) OR (@drop_recreate = 1))
	BEGIN
		SET @_output += ''<br>Inside Step 02: Create main table if Not Exists..''+CHAR(10);
		IF (@drop_recreate = 1)
		BEGIN
			IF @verbose > 0
				PRINT CHAR(9)+''Inside Step 02: Drop main table if exists..'';
			SET @_s = ''if object_id(''''''+@destination_table+'''''') is not null drop table ''+@destination_table;
			IF @verbose > 1
				PRINT CHAR(9)+@_s;
			EXEC(@_s)
		END

		IF @verbose > 0
			PRINT CHAR(9)+''Inside Step 02: Generate main table create script with @output_column_list..'';
		EXEC dbo.sp_WhoIsActive @get_outer_command=1, @get_task_info=2, @find_block_leaders=1, @get_plans=1, @get_avg_time=1, @get_additional_info=1, @delta_interval = 10
				,@output_column_list = @output_column_list
				,@return_schema = 1, @schema = @_s OUTPUT; 
		SET @_s = REPLACE(@_s, ''<table_name>'', @destination_table) 
	
		DECLARE @insert_position int = CHARINDEX ( '','' , @_s )
		SET @_s = LEFT(@_s, @insert_position)+''[host_cpu_percent] tinyint NOT NULL DEFAULT 0,[cpu_rank] smallint NOT NULL DEFAULT 0,[CPU_delta_percent] tinyint NOT NULL, [pool] varchar(30) NULL,''+RIGHT(@_s,LEN(@_s)-@insert_position)+'';''
		SET @insert_position = CHARINDEX('');'',@_s);
		SET @_s = LEFT(@_s, @insert_position-1)+'',[CPU_delta_all] bigint NOT NULL);''
		
		IF @verbose > 0
			PRINT CHAR(9)+''Inside Step 02: Create main table with @output_column_list with additional *cpu* columns..'';
		IF @verbose > 1
			PRINT CHAR(9)+@_s;
		EXEC(@_s)
	END
	IF @verbose > 0
		PRINT ''End Step 02: Create main table if Not Exists..''+char(10);

	--	Step 03: Add a clustered Index
	IF @verbose > 0
		PRINT ''Start Step 03: Add a clustered Index..'';
	IF NOT EXISTS (select * from sys.indexes i where i.type_desc = ''CLUSTERED'' and i.object_id = OBJECT_ID(@destination_table))
	BEGIN
		SET @_output += ''<br>Inside Step 03: Add a clustered Index..''+CHAR(10);
		IF @verbose > 0
			PRINT CHAR(9)+''Inside Step 03: Add primary key clustered..'';
		SET @_s = ''ALTER TABLE ''+@destination_table+'' ADD CONSTRAINT pk_''+SUBSTRING(@destination_table,CHARINDEX(''.'',@destination_table)+1,LEN(@destination_table))+'' PRIMARY KEY CLUSTERED ( [collection_time] ASC, cpu_rank )'';
		IF @verbose > 1
			PRINT CHAR(9)+@_s;
		EXEC (@_s);
		IF @verbose > 0
			PRINT CHAR(9)+''Inside Step 03: Add duration_minutes column..'';
		SET @_s = ''ALTER TABLE ''+@destination_table+'' ADD duration_minutes AS DATEDIFF_BIG(MILLISECOND,start_time,collection_time)/1000/60'';
		IF @verbose > 1
			PRINT CHAR(9)+@_s;
		EXEC (@_s);
	END
	IF @verbose > 0
		PRINT ''End Step 03: Add a clustered Index..''+char(10);

	-- Step 04: Purge Old data
	IF @verbose > 0
		PRINT ''Start Step 04: Purge Old data..'';
	SET @_output += ''<br>Execute Step 04: Purge Old data..''+CHAR(10);
	SET @_s = ''DELETE FROM ''+@destination_table+'' where collection_time < DATEADD(day,-''+cast(@retention_day as varchar)+'',getdate());''
	IF @verbose > 1
		PRINT CHAR(9)+@_s;
	EXEC(@_s);
	IF @verbose > 0
		PRINT ''End Step 04: Purge Old data..''+char(10);

	-- Step 05: Populate Staging table
	IF @verbose > 0
		PRINT ''Start Step 05: Populate Staging table..'';
	SET @_output += ''<br>Execute Step 05: Populate Staging table..''+CHAR(10);
	EXEC dbo.sp_WhoIsActive @get_outer_command=1, @get_task_info=2, @find_block_leaders=1, @get_plans=1, @get_avg_time=1, @get_additional_info=1, @delta_interval = 10
				,@output_column_list = @output_column_list
				,@destination_table = @staging_table;
	SET @_rows_affected = ISNULL(@@ROWCOUNT,0);
	SET @_output += ''<br>@_rows_affected is set from @@ROWCOUNT.''+CHAR(10);
	IF @verbose > 0
		PRINT ''End Step 05: Populate Staging table..''+char(10);

	IF @is_test_alert = 1
		PRINT 1/0;

	-- Step 06: Populate Main table
	IF @verbose > 0
		PRINT ''Start Step 06: Populate Main table..'';
	SET @_output += ''<br>Execute Step 06: Populate Main table..''+CHAR(10);
	
	IF @verbose > 0
		PRINT CHAR(9)+''Inside Step 06: Get comma separated list of columns..'';
	SELECT @_columns = COALESCE(@_columns+'',''+QUOTENAME(c.COLUMN_NAME),QUOTENAME(c.COLUMN_NAME)) 
	FROM INFORMATION_SCHEMA.COLUMNS c WHERE OBJECT_ID(c.TABLE_SCHEMA+''.''+TABLE_NAME) = OBJECT_ID(@staging_table)
	ORDER BY c.ORDINAL_POSITION;

	SET @_output += ''<br>Fetch @_cpu_system & @_cpu_sql..''+CHAR(10);
	IF @verbose > 0
		PRINT CHAR(9)+''Inside Step 06: Get system & sql cpu into variables..'';
	SELECT	@_cpu_system = CASE WHEN system_cpu_utilization_post_sp2 IS NOT NULL THEN system_cpu_utilization_post_sp2 ELSE system_cpu_utilization_pre_sp2 END,  
			@_cpu_sql = CASE WHEN sql_cpu_utilization_post_sp2 IS NOT NULL THEN sql_cpu_utilization_post_sp2 ELSE sql_cpu_utilization_pre_sp2 END
	FROM  (	SELECT	record.value(''(Record/@id)[1]'', ''int'') AS record_id,
					DATEADD (ms, -1 * (ts_now - [timestamp]), GETDATE()) AS EventTime,
					100-record.value(''(Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]'', ''int'') AS system_cpu_utilization_post_sp2, 
					record.value(''(Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]'', ''int'') AS sql_cpu_utilization_post_sp2,
					100-record.value(''(Record/SchedluerMonitorEvent/SystemHealth/SystemIdle)[1]'', ''int'') AS system_cpu_utilization_pre_sp2,
					record.value(''(Record/SchedluerMonitorEvent/SystemHealth/ProcessUtilization)[1]'', ''int'') AS sql_cpu_utilization_pre_sp2
			FROM (	SELECT	timestamp, CONVERT (xml, record) AS record, cpu_ticks / (cpu_ticks/ms_ticks) as ts_now
					FROM sys.dm_os_ring_buffers cross apply sys.dm_os_sys_info
					WHERE ring_buffer_type = ''RING_BUFFER_SCHEDULER_MONITOR''
					AND record LIKE ''%<SystemHealth>%''
					) AS t 
			) AS t
	ORDER BY EventTime DESC OFFSET 0 ROWS FETCH FIRST 1 ROWS ONLY;
	
	IF @verbose > 0
		PRINT CHAR(9)+''Inside Step 06: Calculate cpu_rank, CPU_delta_percent, pool & CPU_delta_all..'';
	SET @_output += ''<br>Calculate cpu_rank, CPU_delta_percent, pool & CPU_delta_all..''+CHAR(10);
	SET @_s = ''
	INSERT ''+@destination_table+''
	([host_cpu_percent],[cpu_rank],[CPU_delta_percent],[pool],''+@_columns+'',[CPU_delta_all])'';
	IF EXISTS (select * from sys.resource_governor_configuration where is_enabled = 1)
	BEGIN
		SET @_s = @_s + ''
	SELECT ''+CONVERT(varchar,@_cpu_system)+'' as [host_cpu_percent],
			[cpu_rank] = ROW_NUMBER()OVER(ORDER BY CPU_delta DESC, CPU DESC, start_time ASC, session_id, GETDATE()), 
			[CPU_delta_percent] = CONVERT(tinyint,CASE WHEN SUM(CONVERT(bigint,REPLACE(CPU_delta,'''','''',''''''''))) over(partition by collection_time) = 0
												THEN 0
												ELSE ISNULL(CONVERT(bigint,REPLACE(CPU_delta,'''','''',''''''''))*100/SUM(CONVERT(bigint,REPLACE(CPU_delta,'''','''',''''''''))) over(partition by collection_time),0)
												END),
			[pool] = ISNULL(rg.pool,''''REST''''),
			''+@_columns+'',
			[CPU_delta_all] = ISNULL(SUM(CONVERT(bigint,REPLACE(CPU_delta,'''','''',''''''''))) over(partition by collection_time),0)
	FROM ''+@staging_table+'' s
	OUTER APPLY (	SELECT rp.name as [pool]
						FROM sys.dm_resource_governor_workload_groups wg
						JOIN sys.dm_resource_governor_resource_pools rp
						ON rp.pool_id = wg.pool_id
						WHERE wg.group_id = s.additional_info.value(''''(/additional_info/group_id)[1]'''',''''int'''')
			) rg
	ORDER BY cpu_rank;'';
	END
	ELSE
	BEGIN
		SET @_s = @_s + ''
	SELECT ''+CONVERT(varchar,@_cpu_system)+'' as [host_cpu_percent],
			[cpu_rank] = ROW_NUMBER()OVER(ORDER BY CPU_delta DESC, CPU DESC, start_time ASC, session_id, GETDATE()),
			[CPU_delta_percent] = CONVERT(tinyint,CASE WHEN SUM(CONVERT(bigint,REPLACE(CPU_delta,'''','''',''''''''))) over(partition by collection_time) = 0
												THEN 0
												ELSE ISNULL(CONVERT(bigint,REPLACE(CPU_delta,'''','''',''''''''))*100/SUM(CONVERT(bigint,REPLACE(CPU_delta,'''','''',''''''''))) over(partition by collection_time),0)
												END),
			[pool] = ''''REST'''',
			''+@_columns+'',
			[CPU_delta_all] = ISNULL(SUM(CONVERT(bigint,REPLACE(CPU_delta,'''','''',''''''''))) over(partition by collection_time),0)
	FROM ''+@staging_table+'' s
	ORDER BY cpu_rank;'';
	END
	SET @_output += ''<br>Populate Main table..''+CHAR(10);
	IF @verbose > 1
		PRINT @_s
	EXEC(@_s);
	IF @verbose > 0
		PRINT ''End Step 06: Populate Main table..'';
	
	-- Step 07: Return rows affected
	SET @_output += ''<br>Execute Step 07: Return rows affected..''+CHAR(10);
	PRINT ''[rows_affected] = ''+CONVERT(varchar,ISNULL(@_rows_affected,0));
	SET @_output += ''<br>FINISH. Script executed without error.''+CHAR(10);
	IF @verbose > 0
		PRINT ''End Step 07: Return rows affected. Script completed without error''
END TRY  -- Perform main logic inside Try/Catch
BEGIN CATCH
	IF @verbose > 0
		PRINT ''Start Catch Block.''

	SELECT @_errorNumber	 = Error_Number()
			,@_errorSeverity = Error_Severity()
			,@_errorState	 = Error_State()
			,@_errorLine	 = Error_Line()
			,@_errorMessage	 = Error_Message();

	IF OBJECT_ID(''tempdb..#CommandLog'') IS NOT NULL
		TRUNCATE TABLE #CommandLog;
	ELSE
		CREATE TABLE #CommandLog(collection_time datetime2 not null, status varchar(30) not null);

	IF @verbose > 0
		PRINT CHAR(9)+''Inside Catch Block. Get recent ''+cast(@threshold_continous_failure as varchar)+'' execution entries from logs..''
	SET @_s = N''
	DECLARE @threshold_continous_failure tinyint = @_threshold_continous_failure;
	SET @threshold_continous_failure -= 1;
	SELECT	[run_date_time] = msdb.dbo.agent_datetime(run_date, run_time),
			[status] = case when run_status = 1 then ''''Success'''' else ''''Failure'''' end
	FROM msdb.dbo.sysjobs jobs
	INNER JOIN msdb.dbo.sysjobhistory history ON jobs.job_id = history.job_id
	WHERE jobs.enabled = 1 AND jobs.name = @_job_name AND step_id = 0 AND run_status NOT IN (2,4) -- not retry/inprogress
	ORDER BY run_date_time DESC OFFSET 0 ROWS FETCH FIRST @threshold_continous_failure ROWS ONLY;'' + char(10);
	IF @verbose > 1
		PRINT CHAR(9)+@_s;
	INSERT #CommandLog
	EXEC sp_executesql @_s, N''@_job_name varchar(500), @_threshold_continous_failure tinyint'', @_job_name = @_job_name, @_threshold_continous_failure = @threshold_continous_failure;

	SELECT @_continous_failures = COUNT(*)+1 FROM #CommandLog WHERE [status] = ''Failure'';

	IF @verbose > 0
		PRINT CHAR(9)+''@_continous_failures => ''+cast(@_continous_failures as varchar);
	IF @verbose > 1
	BEGIN
		PRINT CHAR(9)+''SELECT [RunningQuery] = ''''Previous Run Status from #CommandLog'''', * FROM #CommandLog;''
		SELECT [RunningQuery], cl.* 
		FROM #CommandLog cl
		FULL OUTER JOIN (VALUES (''Previous Run Status from #CommandLog'')) rq (RunningQuery)
		ON 1 = 1;
	END

	IF @verbose > 0
		PRINT ''End Catch Block.''
END CATCH	

/* 
Check if Any Error, then based on Continous Threshold & Delay, send mail
Check if No Error, then clear the alert if active,
*/

IF @verbose > 0
	PRINT ''Get Last @last_sent_failed &  @last_sent_cleared..'';
SELECT @_last_sent_failed_active = MAX(si.sent_date) FROM msdb..sysmail_sentitems si WHERE si.subject LIKE (''% - Job ![''+@_job_name+''!] - ![FAILED!] - ![ACTIVE!]'') ESCAPE ''!'';
SELECT @_last_sent_failed_cleared = MAX(si.sent_date) FROM msdb..sysmail_sentitems si WHERE si.subject LIKE (''% - Job ![''+@_job_name+''!] - ![FAILED!] - ![CLEARED!]'') ESCAPE ''!'';

IF @verbose > 0
BEGIN
	PRINT ''@_last_sent_failed_active => ''+CONVERT(nvarchar(30),@_last_sent_failed_active,121);
	PRINT ''@_last_sent_failed_cleared => ''+ISNULL(CONVERT(nvarchar(30),@_last_sent_failed_cleared,121),'''');
END

-- Check if Failed, @threshold_continous_failure is breached, and crossed @notification_delay_minutes
IF		(@send_error_mail = 1) 
	AND (@_continous_failures >= @threshold_continous_failure) 
	AND ( (@_last_sent_failed_active IS NULL) OR (DATEDIFF(MINUTE,@_last_sent_failed_active,GETDATE()) >= @notification_delay_minutes) )
BEGIN
	IF @verbose > 0
		PRINT ''Setting Mail variable values for Job FAILED ACTIVE notification..''
	SET @_subject = QUOTENAME(@@SERVERNAME)+'' - Job [''+@_job_name+''] - [FAILED] - [ACTIVE]'';
	SET @_mail_body_html =
			N''Sql Agent job ''''''+@_job_name+'''''' has failed @''+ CONVERT(nvarchar(30),getdate(),121) +''.''+
			N''<br><br>Error Number: '' + convert(varchar, @_errorNumber) + 
			N''<br>Line Number: '' + convert(varchar, @_errorLine) +
			N''<br>Error Message: <br>"'' + @_errorMessage +
			N''<br><br>Kindly resolve the job failure based on above error message.''+
			N''<br><br>Below is Job Output till now -><br><br>''+@_output+
			N''<br><br>Regards,''+
			N''<br>Job [''+@_job_name+'']'' +
			N''<br><br>--> Continous Failure Threshold -> '' + CONVERT(varchar,@threshold_continous_failure) +
			N''<br>--> Notification Delay (Minutes) -> '' + CONVERT(varchar,@notification_delay_minutes)
	SET @_send_mail = 1;
END
ELSE
	PRINT ''IMPORTANT => Failure "Active" mail notification checks not satisfied. ''+char(10)+char(9)+''((@send_error_mail = 1) AND (@_continous_failures >= @threshold_continous_failure) AND ( (@last_sent_failed IS NULL) OR (DATEDIFF(MINUTE,@last_sent_failed,GETDATE()) >= @notification_delay_minutes) ))'';

-- Check if No error, then clear active alert if any.
IF (@send_error_mail = 1) AND (@_errorMessage IS NULL) AND (@_last_sent_failed_active >= ISNULL(@_last_sent_failed_cleared,@_last_sent_failed_active))
BEGIN
	IF @verbose > 0
		PRINT ''Setting Mail variable values for Job FAILED CLEARED notification..''
	SET @_subject = QUOTENAME(@@SERVERNAME)+'' - Job [''+@_job_name+''] - [FAILED] - [CLEARED]'';
	SET @_mail_body_html =
			N''Sql Agent job ''''''+@_job_name+'''''' has completed successfully. So clearing alert @''+ CONVERT(nvarchar(30),getdate(),121) +''.''+
			N''<br><br>Regards,''+
			N''<br>Job [''+@_job_name+'']'' +
			N''<br><br>--> Continous Failure Threshold -> '' + CONVERT(varchar,@threshold_continous_failure) +
			N''<br>--> Notification Delay (Minutes) -> '' + CONVERT(varchar,@notification_delay_minutes)
	SET @_send_mail = 1;
END
ELSE
	PRINT ''IMPORTANT => Failure "Clearing" mail notification checks not satisfied. ''+char(10)+char(9)+''(@send_error_mail = 1) AND (@_errorMessage IS NULL) AND (@_last_sent_failed_active > @_last_sent_failed_cleared)'';

IF @is_test_alert = 1
	SET @_subject = ''TestAlert - ''+@_subject;

IF @_send_mail = 1
BEGIN
	SELECT @_profile_name = p.name
	FROM msdb.dbo.sysmail_profile p 
	JOIN msdb.dbo.sysmail_principalprofile pp ON pp.profile_id = p.profile_id AND pp.is_default = 1
	JOIN msdb.dbo.sysmail_profileaccount pa ON p.profile_id = pa.profile_id 
	JOIN msdb.dbo.sysmail_account a ON pa.account_id = a.account_id 
	JOIN msdb.dbo.sysmail_server s ON a.account_id = s.account_id;

	EXEC msdb.dbo.sp_send_dbmail
			@recipients = @recipients,
			@profile_name = @_profile_name,
			@subject = @_subject,
			@body = @_mail_body_html,
			@body_format = ''HTML'';
END

IF @_errorMessage IS NOT NULL --AND @send_error_mail = 0
	THROW 50000, @_errorMessage, 1;', 
		@database_name=N'DBA', 
		@flags=12
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'(dba) Run-WhoIsActive', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=2, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20220315, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'a8747517-f968-4e52-8c17-d9c77bd5b2cf'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


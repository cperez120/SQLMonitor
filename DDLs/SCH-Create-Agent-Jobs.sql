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

BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'(dba) Monitoring & Alerting' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'(dba) Monitoring & Alerting'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'(dba) Collect-PerfmonData', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job captures Perfmon data as per template 

https://github.com/imajaydwivedi/SqlServer-Baselining-Grafana/blob/master/NonSql-Files/DBA_PerfMon_All_Counters_Template.xml', 
		@category_name=N'(dba) Monitoring & Alerting', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQLAgentService', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

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


BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'(dba) Monitoring & Alerting' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'(dba) Monitoring & Alerting'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'(dba) Partitions-Maintenance', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job takes care of creating new partitions and removing old partitions', 
		@category_name=N'(dba) Monitoring & Alerting', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQLAgentService', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Add partitions - Hourly - Till Next Quarter End', 
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

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Remove Partitions - Retain upto 3 Months', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'set nocount on;
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


USE [msdb]
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
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'(dba) Purge-DbaMetrics - Daily', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Cleanup tables -

dbo.performance_counters
dbo.perfmon_files', 
		@category_name=N'(dba) Monitoring & Alerting', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQLAgentService', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

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


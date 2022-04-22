use msdb
go

IF EXISTS (SELECT * FROM msdb.dbo.sysjobs_view WHERE name = N'(dba) Collect-WaitStats')
	EXEC msdb.dbo.sp_delete_job @job_name='(dba) Collect-WaitStats', @delete_unused_schedule=1
GO

USE [msdb]
GO

/****** Object:  Job [(dba) Collect-WaitStats]    Script Date: 4/22/2022 9:41:03 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [(dba) Monitoring & Alerting]    Script Date: 4/22/2022 9:41:03 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'(dba) Monitoring & Alerting' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'(dba) Monitoring & Alerting'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'(dba) Collect-WaitStats', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'(dba) Monitoring & Alerting', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [WaitStats]    Script Date: 4/22/2022 9:41:04 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'WaitStats', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_WARNINGS ON;

-- Parameters
DECLARE @send_error_mail bit = 1;
DECLARE @blocking_threshold_minutes tinyint = 2;
DECLARE @threshold_continous_failure tinyint = 3;
DECLARE @notification_delay_minutes tinyint = 10;
DECLARE @is_test_alert bit = 0;
DECLARE @verbose tinyint = 0; /* 0 - no messages, 1 - debug messages, 2 = debug messages + table results */
DECLARE @recipients varchar(500) = ''sqlagentservice@gmail.com'' --''some_dba_mail_id@gmail.com'';
DECLARE @alert_key varchar(100) = ''Collect-WaitStats'';

/* Additional Requirements
1) Default Global Mail Profile
	-> SqlInstance -> Management -> Right click "Database Mail" -> Configure Database Mail -> Select option "Manage profile security" -> Check Public checkbox, and Select "Yes" for Default for profile that should be set a global default
2) Make sure context database is set to correct dba database
*/

--DECLARE @_output VARCHAR(8000);
--SET @_output = ''Declare local variables''+CHAR(10);
-- Local Variables
--DECLARE @_rows_affected int = 0;
DECLARE @_s NVARCHAR(MAX);
DECLARE @_collection_time datetime = GETDATE();
--DECLARE @_columns VARCHAR(8000);
--DECLARE @_cpu_system int;
--DECLARE @_cpu_sql int;
DECLARE @_last_sent_failed_active datetime;
DECLARE @_last_sent_failed_cleared datetime;
DECLARE @_mail_body_html NVARCHAR(MAX);  
DECLARE @_subject nvarchar(1000);
DECLARE @_job_name nvarchar(500);
DECLARE @_continous_failures tinyint = 0;
DECLARE @_send_mail bit = 0;

SET @_job_name = ''(dba) ''+@alert_key;

IF @recipients IS NULL OR @recipients = ''some_dba_mail_id@gmail.com''
	THROW 50000, ''@recipients is mandatory parameter'', 1;

-- Variables for Try/Catch Block
DECLARE @_profile_name varchar(200);
DECLARE	@_errorNumber int,
		@_errorSeverity int,
		@_errorState int,
		@_errorLine int,
		@_errorMessage nvarchar(4000);

BEGIN TRY
	IF @verbose > 0
		PRINT ''Start Try Block..'';	
	INSERT [dbo].[wait_stats]
	([collection_time_utc], [wait_type], [waiting_tasks_count], [wait_time_ms], [max_wait_time_ms], [signal_wait_time_ms])
	SELECT [collection_time_utc] = sysutcdatetime(), [wait_type], [waiting_tasks_count], [wait_time_ms], [max_wait_time_ms], [signal_wait_time_ms]
	FROM sys.dm_os_wait_stats
	WHERE [waiting_tasks_count] > 0;
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
	SET @_mail_body_html=
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
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'(dba) Collect-WaitStats', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200820, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'edf61f10-a94c-4a92-b2b4-c0baee7043ff'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


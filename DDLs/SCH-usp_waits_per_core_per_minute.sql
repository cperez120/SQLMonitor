IF DB_NAME() = 'master'
	raiserror ('Kindly execute all queries in [DBA] database', 20, -1) with log;
go

SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ANSI_WARNINGS ON;
SET NUMERIC_ROUNDABORT OFF;
SET ARITHABORT ON;
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'usp_waits_per_core_per_minute')
    EXEC ('CREATE PROC dbo.usp_waits_per_core_per_minute AS SELECT ''stub version, to be replaced''')
GO

ALTER PROCEDURE dbo.usp_waits_per_core_per_minute
	@waits_seconds__per_core_per_minute decimal(20,2) = -1.0 output
WITH RECOMPILE, EXECUTE AS OWNER AS 
BEGIN

	/*
		Version:		1.0.0
		Date:			2022-07-15

		declare @waits_seconds__per_core_per_minute bigint;
		exec usp_waits_per_core_per_minute @waits_seconds__per_core_per_minute = @waits_seconds__per_core_per_minute output;
		select [waits_seconds__per_core_per_minute] = @waits_seconds__per_core_per_minute;
	*/
	SET NOCOUNT ON; 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET LOCK_TIMEOUT 30000; -- 30 seconds
	
	DECLARE @passed_waits_seconds__per_core_per_minute smallint = @waits_seconds__per_core_per_minute;
	declare @schedulers smallint;
	select @schedulers = count(*) from sys.dm_os_schedulers where status = 'VISIBLE ONLINE' and is_online = 1;

	/* Ajay (2022-07-15 => Due to ErrorNumber 11526, "The metadata could not be determined ", changing #temptables to table variables */
	--IF OBJECT_ID('tempdb..@SQLskillsStats1') IS NOT NULL
	--	DROP TABLE @SQLskillsStats1;
	--IF OBJECT_ID('tempdb..#SQLskillsStats2') IS NOT NULL
	--	DROP TABLE #SQLskillsStats2;  
	declare @SQLskillsStats1 table ([wait_type] nvarchar(120), [waiting_tasks_count] bigint, [wait_time_ms] bigint);
	declare @SQLskillsStats2 table ([wait_type] nvarchar(120), [waiting_tasks_count] bigint, [wait_time_ms] bigint);
  
	DECLARE @collection_time_utc_snap1 datetime2;
	DECLARE @collection_time_utc_snap2 datetime2;

	DECLARE @Waits2Skip TABLE (wait_type nvarchar(120));
	INSERT @Waits2Skip (wait_type)
	SELECT wait_type
	FROM (VALUES 	(N'BROKER_EVENTHANDLER'), -- https://www.sqlskills.com/help/waits/BROKER_EVENTHANDLER
					(N'BROKER_RECEIVE_WAITFOR'), -- https://www.sqlskills.com/help/waits/BROKER_RECEIVE_WAITFOR
					(N'BROKER_TASK_STOP'), -- https://www.sqlskills.com/help/waits/BROKER_TASK_STOP
					(N'BROKER_TO_FLUSH'), -- https://www.sqlskills.com/help/waits/BROKER_TO_FLUSH
					(N'BROKER_TRANSMITTER'), -- https://www.sqlskills.com/help/waits/BROKER_TRANSMITTER
					(N'CHECKPOINT_QUEUE'), -- https://www.sqlskills.com/help/waits/CHECKPOINT_QUEUE
					(N'CHKPT'), -- https://www.sqlskills.com/help/waits/CHKPT
					(N'CLR_AUTO_EVENT'), -- https://www.sqlskills.com/help/waits/CLR_AUTO_EVENT
					(N'CLR_MANUAL_EVENT'), -- https://www.sqlskills.com/help/waits/CLR_MANUAL_EVENT
					(N'CLR_SEMAPHORE'), -- https://www.sqlskills.com/help/waits/CLR_SEMAPHORE
					(N'CXCONSUMER'), -- https://www.sqlskills.com/help/waits/CXCONSUMER 
					(N'DIRTY_PAGE_POLL'), -- https://www.sqlskills.com/help/waits/DIRTY_PAGE_POLL
					(N'DISPATCHER_QUEUE_SEMAPHORE'), -- https://www.sqlskills.com/help/waits/DISPATCHER_QUEUE_SEMAPHORE
					(N'EXECSYNC'), -- https://www.sqlskills.com/help/waits/EXECSYNC
					(N'FSAGENT'), -- https://www.sqlskills.com/help/waits/FSAGENT
					(N'FT_IFTS_SCHEDULER_IDLE_WAIT'), -- https://www.sqlskills.com/help/waits/FT_IFTS_SCHEDULER_IDLE_WAIT
					(N'FT_IFTSHC_MUTEX'), -- https://www.sqlskills.com/help/waits/FT_IFTSHC_MUTEX
					(N'KSOURCE_WAKEUP'), -- https://www.sqlskills.com/help/waits/KSOURCE_WAKEUP
					(N'LAZYWRITER_SLEEP'), -- https://www.sqlskills.com/help/waits/LAZYWRITER_SLEEP
					(N'LOGMGR_QUEUE'), -- https://www.sqlskills.com/help/waits/LOGMGR_QUEUE
					(N'MEMORY_ALLOCATION_EXT'), -- https://www.sqlskills.com/help/waits/MEMORY_ALLOCATION_EXT
					(N'ONDEMAND_TASK_QUEUE'), -- https://www.sqlskills.com/help/waits/ONDEMAND_TASK_QUEUE
					(N'PARALLEL_REDO_DRAIN_WORKER'), -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_DRAIN_WORKER
					(N'PARALLEL_REDO_LOG_CACHE'), -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_LOG_CACHE
					(N'PARALLEL_REDO_TRAN_LIST'), -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_TRAN_LIST
					(N'PARALLEL_REDO_WORKER_SYNC'), -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_WORKER_SYNC
					(N'PARALLEL_REDO_WORKER_WAIT_WORK'), -- https://www.sqlskills.com/help/waits/PARALLEL_REDO_WORKER_WAIT_WORK
					(N'PREEMPTIVE_XE_GETTARGETSTATE'), -- https://www.sqlskills.com/help/waits/PREEMPTIVE_XE_GETTARGETSTATE
					(N'PWAIT_ALL_COMPONENTS_INITIALIZED'), -- https://www.sqlskills.com/help/waits/PWAIT_ALL_COMPONENTS_INITIALIZED
					(N'PWAIT_DIRECTLOGCONSUMER_GETNEXT'), -- https://www.sqlskills.com/help/waits/PWAIT_DIRECTLOGCONSUMER_GETNEXT
					(N'QDS_PERSIST_TASK_MAIN_LOOP_SLEEP'), -- https://www.sqlskills.com/help/waits/QDS_PERSIST_TASK_MAIN_LOOP_SLEEP
					(N'QDS_ASYNC_QUEUE'), -- https://www.sqlskills.com/help/waits/QDS_ASYNC_QUEUE
					(N'QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP'), -- https://www.sqlskills.com/help/waits/QDS_CLEANUP_STALE_QUERIES_TASK_MAIN_LOOP_SLEEP
					(N'QDS_SHUTDOWN_QUEUE'), -- https://www.sqlskills.com/help/waits/QDS_SHUTDOWN_QUEUE
					(N'REDO_THREAD_PENDING_WORK'), -- https://www.sqlskills.com/help/waits/REDO_THREAD_PENDING_WORK
					(N'REQUEST_FOR_DEADLOCK_SEARCH'), -- https://www.sqlskills.com/help/waits/REQUEST_FOR_DEADLOCK_SEARCH
					(N'RESOURCE_QUEUE'), -- https://www.sqlskills.com/help/waits/RESOURCE_QUEUE
					(N'SERVER_IDLE_CHECK'), -- https://www.sqlskills.com/help/waits/SERVER_IDLE_CHECK
					(N'SLEEP_BPOOL_FLUSH'), -- https://www.sqlskills.com/help/waits/SLEEP_BPOOL_FLUSH
					(N'SLEEP_DBSTARTUP'), -- https://www.sqlskills.com/help/waits/SLEEP_DBSTARTUP
					(N'SLEEP_DCOMSTARTUP'), -- https://www.sqlskills.com/help/waits/SLEEP_DCOMSTARTUP
					(N'SLEEP_MASTERDBREADY'), -- https://www.sqlskills.com/help/waits/SLEEP_MASTERDBREADY
					(N'SLEEP_MASTERMDREADY'), -- https://www.sqlskills.com/help/waits/SLEEP_MASTERMDREADY
					(N'SLEEP_MASTERUPGRADED'), -- https://www.sqlskills.com/help/waits/SLEEP_MASTERUPGRADED
					(N'SLEEP_MSDBSTARTUP'), -- https://www.sqlskills.com/help/waits/SLEEP_MSDBSTARTUP
					(N'SLEEP_SYSTEMTASK'), -- https://www.sqlskills.com/help/waits/SLEEP_SYSTEMTASK
					(N'SLEEP_TASK'), -- https://www.sqlskills.com/help/waits/SLEEP_TASK
					(N'SLEEP_TEMPDBSTARTUP'), -- https://www.sqlskills.com/help/waits/SLEEP_TEMPDBSTARTUP
					(N'SNI_HTTP_ACCEPT'), -- https://www.sqlskills.com/help/waits/SNI_HTTP_ACCEPT
					(N'SOS_WORK_DISPATCHER'), -- https://www.sqlskills.com/help/waits/SOS_WORK_DISPATCHER
					(N'SP_SERVER_DIAGNOSTICS_SLEEP'), -- https://www.sqlskills.com/help/waits/SP_SERVER_DIAGNOSTICS_SLEEP
					(N'SQLTRACE_BUFFER_FLUSH'), -- https://www.sqlskills.com/help/waits/SQLTRACE_BUFFER_FLUSH
					(N'SQLTRACE_INCREMENTAL_FLUSH_SLEEP'), -- https://www.sqlskills.com/help/waits/SQLTRACE_INCREMENTAL_FLUSH_SLEEP
					(N'SQLTRACE_WAIT_ENTRIES'), -- https://www.sqlskills.com/help/waits/SQLTRACE_WAIT_ENTRIES
					(N'WAIT_FOR_RESULTS'), -- https://www.sqlskills.com/help/waits/WAIT_FOR_RESULTS
					(N'WAITFOR'), -- https://www.sqlskills.com/help/waits/WAITFOR
					(N'WAITFOR_TASKSHUTDOWN'), -- https://www.sqlskills.com/help/waits/WAITFOR_TASKSHUTDOWN
					(N'WAIT_XTP_RECOVERY'), -- https://www.sqlskills.com/help/waits/WAIT_XTP_RECOVERY
					(N'WAIT_XTP_HOST_WAIT'), -- https://www.sqlskills.com/help/waits/WAIT_XTP_HOST_WAIT
					(N'WAIT_XTP_OFFLINE_CKPT_NEW_LOG'), -- https://www.sqlskills.com/help/waits/WAIT_XTP_OFFLINE_CKPT_NEW_LOG
					(N'WAIT_XTP_CKPT_CLOSE'), -- https://www.sqlskills.com/help/waits/WAIT_XTP_CKPT_CLOSE
					(N'XE_DISPATCHER_JOIN'), -- https://www.sqlskills.com/help/waits/XE_DISPATCHER_JOIN
					(N'XE_DISPATCHER_WAIT'), -- https://www.sqlskills.com/help/waits/XE_DISPATCHER_WAIT
					(N'XE_TIMER_EVENT') -- https://www.sqlskills.com/help/waits/XE_TIMER_EVENT
			) Waits (wait_type);


	-- Collect data from dbo.wait_stats for 1st snapshot
	select top 1 @collection_time_utc_snap1 = wi.collection_time_utc from dbo.wait_stats wi order by wi.collection_time_utc desc;

	insert @SQLskillsStats1 ([wait_type], [waiting_tasks_count], [wait_time_ms])
	select [wait_type], [waiting_tasks_count], [wait_time_ms] from dbo.wait_stats ws
	where collection_time_utc = @collection_time_utc_snap1 and wait_type NOT IN (SELECT wait_type FROM @Waits2Skip);

	-- Take 2nd snapshot at current moment
	SET @collection_time_utc_snap2 = sysutcdatetime();
	insert @SQLskillsStats2 ([wait_type], [waiting_tasks_count], [wait_time_ms])
	SELECT [wait_type], [waiting_tasks_count], [wait_time_ms]
	FROM sys.dm_os_wait_stats
	WHERE wait_type NOT IN (SELECT wait_type FROM @Waits2Skip);
  
	;WITH [DiffWaits] ([wait_time_ms]) AS
	(
		SELECT
		-- Waits that weren't in the first snapshot
				--[ts2].[wait_type],
				[ts2].[wait_time_ms]
				--[ts2].[signal_wait_time_ms],
				--[ts2].[waiting_tasks_count]
				--,[elapsed_time_ms] = datediff(millisecond, @collection_time_utc_snap1, @collection_time_utc_snap2)
			FROM @SQLskillsStats2 AS [ts2]
			LEFT OUTER JOIN @SQLskillsStats1 AS [ts1]
				ON [ts2].[wait_type] = [ts1].[wait_type]
			WHERE [ts1].[wait_type] IS NULL
			AND [ts2].[wait_time_ms] > 0
		UNION
		SELECT
		-- Diff of waits in both snapshots
				--[ts2].[wait_type],
				[ts2].[wait_time_ms] - [ts1].[wait_time_ms] AS [wait_time_ms]
				--[ts2].[signal_wait_time_ms] - [ts1].[signal_wait_time_ms] AS [signal_wait_time_ms],
				--[ts2].[waiting_tasks_count] - [ts1].[waiting_tasks_count] AS [waiting_tasks_count]
				--[elapsed_time_ms] = datediff(millisecond, @collection_time_utc_snap1, @collection_time_utc_snap2)
			FROM @SQLskillsStats2 AS [ts2]
			LEFT OUTER JOIN @SQLskillsStats1 AS [ts1]
				ON [ts2].[wait_type] = [ts1].[wait_type]
			WHERE [ts1].[wait_type] IS NOT NULL
			AND [ts2].[waiting_tasks_count] - [ts1].[waiting_tasks_count] > 0
			AND [ts2].[wait_time_ms] - [ts1].[wait_time_ms] > 0
	),
	[Waits] ([wait_time_S]) AS 
	(
		SELECT
			--[wait_type],
			[wait_time_S] = SUM([wait_time_ms]*1.0)/1000.0
			/*
			([wait_time_ms] - [signal_wait_time_ms]) AS [ResourceS],
			[signal_wait_time_ms] / 1000.0 AS [SignalS],
			[waiting_tasks_count] AS [WaitCount],
			100.0 * [wait_time_ms] / SUM ([wait_time_ms]) OVER() AS [Percentage],
			ROW_NUMBER() OVER(ORDER BY [wait_time_ms] DESC) AS [RowNum]
			*/
		FROM [DiffWaits]
	)
	select	--[wait_time_seconds__per_core__per_minute] = 
			@waits_seconds__per_core_per_minute = 
			convert(numeric(20,2), [wait_time_S] / @schedulers / datediff(SECOND,@collection_time_utc_snap1,@collection_time_utc_snap2))
			--,[wait_time_S], @schedulers, @collection_time_utc_snap1, @collection_time_utc_snap2
	from Waits;

	--IF @passed_waits_seconds__per_core_per_minute = -1.0
		SELECT @waits_seconds__per_core_per_minute as waits_seconds__per_core_per_minute;
END
GO

IF APP_NAME() = 'Microsoft SQL Server Management Studio - Query'
BEGIN
	--declare @waits_seconds__per_core_per_minute decimal(20,2);
	exec usp_waits_per_core_per_minute --@waits_seconds__per_core_per_minute = @waits_seconds__per_core_per_minute output;
	--select [waits_seconds__per_core_per_minute] = @waits_seconds__per_core_per_minute;
END
go

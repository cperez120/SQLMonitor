IF APP_NAME() = 'Microsoft SQL Server Management Studio - Query'
BEGIN
	SET QUOTED_IDENTIFIER OFF;
	SET ANSI_PADDING ON;
	SET CONCAT_NULL_YIELDS_NULL ON;
	SET ANSI_WARNINGS ON;
	SET NUMERIC_ROUNDABORT OFF;
	SET ARITHABORT ON;
END
GO

IF DB_NAME() = 'master'
	raiserror ('Kindly execute all queries in [DBA] database', 20, -1) with log;
go

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'usp_GetAllServerInfo')
    EXEC ('CREATE PROC dbo.usp_GetAllServerInfo AS SELECT ''stub version, to be replaced''')
GO

-- DROP PROCEDURE dbo.usp_GetAllServerInfo
go

ALTER PROCEDURE dbo.usp_GetAllServerInfo
(	@servers varchar(max) = null, /* comma separated list of servers to query */
	@blocked_threshold_seconds int = 60, 
	@output nvarchar(max) = null, /* comma separated list of columns required in output */
	@result_to_table nvarchar(125) = null, /* temp table that should be populated with result */
	@verbose bit = 0 /* display debugging messages */
)
	WITH EXECUTE AS OWNER --,RECOMPILE
AS
BEGIN

	/*
		Version:		1.0.1
		Date:			2022-07-15

		declare @srv_name varchar(125) = convert(varchar,serverproperty('MachineName'));
		exec dbo.usp_GetAllServerInfo @servers = @srv_name
		--exec dbo.usp_GetAllServerInfo @servers = 'Workstation,SqlPractice,SqlMonitor' ,@output = 'srv_name, os_start_time_utc'
		--exec dbo.usp_GetAllServerInfo @servers = 'SQLMONITOR' ,@output = 'system_high_memory_signal_state'
		https://stackoverflow.com/questions/10191193/how-to-test-linkedservers-connectivity-in-tsql
	*/
	SET NOCOUNT ON; 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET LOCK_TIMEOUT 60000; -- 60 seconds

	DECLARE @_tbl_servers table (srv_name varchar(125));
	DECLARE @_tbl_output_columns table (column_name varchar(125));
	DECLARE @_linked_server_failed bit = 0;
	DECLARE @_sql NVARCHAR(max);
	DECLARE @_isLocalHost bit = 0;
	create table #server_details (
			srv_name varchar(125), at_server_name varchar(125), machine_name varchar(125), server_name varchar(125), ip varchar(30), 
			domain varchar(125), host_name varchar(125), product_version varchar(30), edition varchar(50),
			sqlserver_start_time_utc datetime2, os_cpu decimal(20,2), sql_cpu decimal(20,2), pcnt_kernel_mode decimal(20,2),
			page_faults_kb decimal(20,2), blocked_counts int, blocked_duration_max_seconds bigint, total_physical_memory_kb bigint,
			available_physical_memory_kb bigint, system_high_memory_signal_state varchar(20), physical_memory_in_use_kb decimal(20,2),
			memory_grants_pending int, connection_count int, active_requests_count int, waits_per_core_per_minute decimal(20,2),
			os_start_time_utc datetime2, cpu_count smallint, scheduler_count smallint, major_version_number smallint, minor_version_number smallint
		);

	declare @_srv_name	nvarchar (125);
	declare @_at_server_name	varchar (125);
	declare @_machine_name	varchar (125);
	declare @_server_name	varchar (125);
	declare @_ip	varchar (30);
	declare @_domain	varchar (125);
	declare @_host_name	varchar (125);
	declare @_product_version	varchar (30);
	declare @_edition varchar(50);
	declare @_sqlserver_start_time_utc	datetime2;
	declare @_os_cpu	decimal(20,2);
	declare @_sql_cpu	decimal(20,2);
	declare @_pcnt_kernel_mode	decimal(20,2);
	declare @_page_faults_kb	decimal(20,2);
	declare @_blocked_counts	int;
	declare @_blocked_duration_max_seconds	bigint;
	declare @_total_physical_memory_kb	bigint;
	declare @_available_physical_memory_kb	bigint;
	declare @_system_high_memory_signal_state	varchar (20);
	declare @_physical_memory_in_use_kb	decimal(20,2);
	declare @_memory_grants_pending	int;
	declare @_connection_count	int;
	declare @_active_requests_count	int;
	declare @_waits_per_core_per_minute	decimal(20,2);
	declare @_os_start_time_utc	datetime2;
	declare @_cpu_count int;
	declare @_scheduler_count int;
	declare @_major_version_number smallint;
	declare @_minor_version_number smallint;
	declare @_result table (col_bigint bigint null, col_int int null, col_varchar varchar(125) null, col_decimal decimal(20,2) null, col_datetime datetime2 null);

	;WITH t1(srv_name, [Servers]) AS 
	(
		SELECT	CAST(LEFT(@servers, CHARINDEX(',',@servers+',')-1) AS VARCHAR(500)) as srv_name,
				STUFF(@servers, 1, CHARINDEX(',',@servers+','), '') as [Servers]
		--
		UNION ALL
		--
		SELECT	CAST(LEFT([Servers], CHARINDEX(',',[Servers]+',')-1) AS VARChAR(500)) AS srv_name,
				STUFF([Servers], 1, CHARINDEX(',',[Servers]+','), '')  as [Servers]
		FROM t1
		WHERE [Servers] > ''	
	)
	INSERT @_tbl_servers (srv_name)
	SELECT ltrim(rtrim(srv_name))
	FROM t1
	OPTION (MAXRECURSION 32000);

	-- Extract output column names
	;WITH t1(column_name, [Columns]) AS 
	(
		SELECT	CAST(LEFT(@output, CHARINDEX(',',@output+',')-1) AS VARCHAR(500)) as column_name,
				STUFF(@output, 1, CHARINDEX(',',@output+','), '') as [Columns]
		--
		UNION ALL
		--
		SELECT	CAST(LEFT([Columns], CHARINDEX(',',[Columns]+',')-1) AS VARChAR(500)) AS column_name,
				STUFF([Columns], 1, CHARINDEX(',',[Columns]+','), '')  as [Columns]
		FROM t1
		WHERE [Columns] > ''	
	)
	INSERT @_tbl_output_columns (column_name)
	SELECT ltrim(rtrim(column_name))
	FROM t1
	OPTION (MAXRECURSION 32000);

	DECLARE cur_servers CURSOR LOCAL FORWARD_ONLY FOR
		select distinct srvname = sql_instance 
		from dbo.instance_details
		where is_available = 1
		and (@servers is null or sql_instance in (select srv_name from @_tbl_servers))
		union select convert(varchar,SERVERPROPERTY('ServerName'));

	OPEN cur_servers;
	FETCH NEXT FROM cur_servers INTO @_srv_name;
	
	--set quoted_identifier off;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		if @verbose = 1
			print char(10)+'***** Looping through '+quotename(@_srv_name)+' *******';
		set @_linked_server_failed = 0;
		set @_at_server_name = NULL;
		set @_machine_name = NULL;
		set @_server_name = NULL;
		set @_ip = NULL;
		set @_domain = NULL;
		set @_host_name = NULL;
		set @_product_version = NULL;
		set @_edition = NULL;
		set @_sqlserver_start_time_utc = NULL;
		set @_os_cpu = NULL;
		set @_sql_cpu = NULL;
		set @_pcnt_kernel_mode = NULL;
		set @_page_faults_kb = NULL;
		set @_blocked_counts = NULL;
		set @_blocked_duration_max_seconds = NULL;
		set @_total_physical_memory_kb = NULL;
		set @_available_physical_memory_kb = NULL;
		set @_system_high_memory_signal_state = NULL;
		set @_physical_memory_in_use_kb = NULL;
		set @_memory_grants_pending = NULL;
		set @_connection_count = NULL;
		set @_active_requests_count = NULL;
		set @_waits_per_core_per_minute = NULL;
		set @_os_start_time_utc	= NULL;
		set @_cpu_count = NULL;
		set @_scheduler_count = NULL;
		set @_major_version_number = NULL;
		set @_minor_version_number = NULL;

		-- If not local server
		if (CONVERT(varchar,SERVERPROPERTY('MachineName')) = @_srv_name)
			set @_isLocalHost = 1
		else
		begin
			set @_isLocalHost = 0
			begin try
				--set @_sql = "SELECT	@@servername as srv_name;";
				--set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
				exec sys.sp_testlinkedserver @_srv_name;
			end try
			begin catch
				print '	ERROR => Linked Server '+quotename(@_srv_name)+' not connecting.';

				set @_linked_server_failed = 1;
				--fetch next from cur_servers into @_srv_name;
				--continue;
			end catch;
		end


		-- [@@SERVERNAME] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and (@output is null or exists (select * from @_tbl_output_columns where column_name = 'at_server_name'))
		begin
			delete from @_result;
			set @_sql = "SELECT	[at_server_name] = CONVERT(varchar,  @@SERVERNAME )";
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_varchar)
				exec (@_sql);

				-- set @_ip
				select @_at_server_name = col_varchar from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [machine_name] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and (@output is null or exists (select * from @_tbl_output_columns where column_name = 'machine_name'))
		begin
			delete from @_result;
			set @_sql = "select CONVERT(varchar,SERVERPROPERTY('MachineName')) as [machine_name]";
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_varchar)
				exec (@_sql);

				-- set @_ip
				select @_machine_name = col_varchar from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [server_name] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and (@output is null or exists (select * from @_tbl_output_columns where column_name = 'server_name'))
		begin
			delete from @_result;
			set @_sql = "select CONVERT(varchar,SERVERPROPERTY('ServerName')) as [server_name]";
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_varchar)
				exec (@_sql);

				-- set @_ip
				select @_server_name = col_varchar from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [ip] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and (@output is null or exists (select * from @_tbl_output_columns where column_name = 'ip'))
		begin
			delete from @_result;
			set @_sql = "SELECT	[ip] = CONVERT(varchar,  CONNECTIONPROPERTY('local_net_address') )";
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_varchar)
				exec (@_sql);

				-- set @_ip
				select @_ip = col_varchar from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [domain] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and ( @output is null or exists (select * from @_tbl_output_columns where column_name = 'domain') )
		begin
			delete from @_result;
			set @_sql = "select default_domain() as [domain];";
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_varchar)
				exec (@_sql);

				-- set @_ip
				select @_domain = col_varchar from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [host_name] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and ( @output is null or exists (select * from @_tbl_output_columns where column_name = 'host_name') )
		begin
			delete from @_result;
			set @_sql = "select CONVERT(varchar,SERVERPROPERTY('ComputerNamePhysicalNetBIOS')) as [host_name]";
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_varchar)
				exec (@_sql);

				-- set @_ip
				select @_host_name = col_varchar from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [product_version] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and ( @output is null or exists (select * from @_tbl_output_columns where column_name = 'product_version') )
		begin
			delete from @_result;
			set @_sql = "select CONVERT(varchar,SERVERPROPERTY('ProductVersion')) as [product_version]";
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_varchar)
				exec (@_sql);

				-- set @_ip
				select @_product_version = col_varchar from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [edition] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and ( @output is null or exists (select * from @_tbl_output_columns where column_name = 'edition') )
		begin
			delete from @_result;
			set @_sql = "select CONVERT(varchar,SERVERPROPERTY('Edition')) as [Edition]";
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_varchar)
				exec (@_sql);

				-- set @_ip
				select @_edition = col_varchar from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [sqlserver_start_time_utc] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and ( @output is null or exists (select * from @_tbl_output_columns where column_name = 'sqlserver_start_time_utc') )
		begin
			delete from @_result;
			set @_sql = "select [sqlserver_start_time_utc] = DATEADD(mi, DATEDIFF(mi, getdate(), getutcdate()), sqlserver_start_time) from sys.dm_os_sys_info as osi";
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_datetime)
				exec (@_sql);

				-- set @_ip
				select @_sqlserver_start_time_utc = col_datetime from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [os_cpu] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and ( @output is null or exists (select * from @_tbl_output_columns where column_name = 'os_cpu') )
		begin
			delete from @_result;
			set @_sql =  "
SET QUOTED_IDENTIFIER ON;
SELECT system_cpu
FROM (
		SELECT	DATEADD (ms, -1 * (ts_now - [timestamp]), GETDATE()) AS event_time
				,DATEADD(mi, DATEDIFF(mi, getdate(), getutcdate()), DATEADD (ms, -1 * (ts_now - [timestamp]), GETDATE())) AS event_time_utc
				,100-record.value('(Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS system_cpu
				,record.value('(Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS sql_cpu
				,record.value('(Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS idle_system_cpu
				,record.value('(Record/SchedulerMonitorEvent/SystemHealth/UserModeTime)[1]', 'bigint')/10000 AS user_mode_time_ms
				,record.value('(Record/SchedulerMonitorEvent/SystemHealth/KernelModeTime)[1]', 'bigint')/10000 AS kernel_mode_time_ms
				,record.value('(Record/SchedulerMonitorEvent/SystemHealth/PageFaults)[1]', 'bigint')*8.0 AS page_faults_kb
				,record
		FROM (	SELECT	TOP 1 timestamp, CONVERT (xml, record) AS record, cpu_ticks / (cpu_ticks/ms_ticks) as ts_now
				FROM sys.dm_os_ring_buffers orb cross apply sys.dm_os_sys_info osi
				WHERE ring_buffer_type = 'RING_BUFFER_SCHEDULER_MONITOR'
				AND record LIKE '%<SystemHealth>%'
				ORDER BY [timestamp] DESC
		) AS rd
) as t;
"
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_decimal)
				exec (@_sql);

				-- set @_ip
				select @_os_cpu = col_decimal from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [sql_cpu] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and ( @output is null or exists (select * from @_tbl_output_columns where column_name = 'sql_cpu') )
		begin
			delete from @_result;
			set @_sql =  "
SET QUOTED_IDENTIFIER ON;
SELECT	sql_cpu
FROM (
		SELECT	DATEADD (ms, -1 * (ts_now - [timestamp]), GETDATE()) AS event_time
				,DATEADD(mi, DATEDIFF(mi, getdate(), getutcdate()), DATEADD (ms, -1 * (ts_now - [timestamp]), GETDATE())) AS event_time_utc
				,100-record.value('(Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS system_cpu
				,record.value('(Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS sql_cpu
				,record.value('(Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS idle_system_cpu
				,record.value('(Record/SchedulerMonitorEvent/SystemHealth/UserModeTime)[1]', 'bigint')/10000 AS user_mode_time_ms
				,record.value('(Record/SchedulerMonitorEvent/SystemHealth/KernelModeTime)[1]', 'bigint')/10000 AS kernel_mode_time_ms
				,record.value('(Record/SchedulerMonitorEvent/SystemHealth/PageFaults)[1]', 'bigint')*8.0 AS page_faults_kb
				,record
		FROM (	SELECT	TOP 1 timestamp, CONVERT (xml, record) AS record, cpu_ticks / (cpu_ticks/ms_ticks) as ts_now
				FROM sys.dm_os_ring_buffers orb cross apply sys.dm_os_sys_info osi
				WHERE ring_buffer_type = 'RING_BUFFER_SCHEDULER_MONITOR'
				AND record LIKE '%<SystemHealth>%'
				ORDER BY [timestamp] DESC
		) AS rd
) as t;

"
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_decimal)
				exec (@_sql);

				-- set @_ip
				select @_sql_cpu = col_decimal from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [pcnt_kernel_mode] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and ( @output is null or exists (select * from @_tbl_output_columns where column_name = 'pcnt_kernel_mode') )
		begin
			delete from @_result;
			set @_sql =  "
SET QUOTED_IDENTIFIER ON;
SELECT	kernel_mode_time_ms * 100 / (user_mode_time_ms + kernel_mode_time_ms) as [pcnt_kernel_mode]
FROM (
		SELECT	DATEADD (ms, -1 * (ts_now - [timestamp]), GETDATE()) AS event_time
				,DATEADD(mi, DATEDIFF(mi, getdate(), getutcdate()), DATEADD (ms, -1 * (ts_now - [timestamp]), GETDATE())) AS event_time_utc
				,100-record.value('(Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS system_cpu
				,record.value('(Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS sql_cpu
				,record.value('(Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS idle_system_cpu
				,record.value('(Record/SchedulerMonitorEvent/SystemHealth/UserModeTime)[1]', 'bigint')/10000 AS user_mode_time_ms
				,record.value('(Record/SchedulerMonitorEvent/SystemHealth/KernelModeTime)[1]', 'bigint')/10000 AS kernel_mode_time_ms
				,record.value('(Record/SchedulerMonitorEvent/SystemHealth/PageFaults)[1]', 'bigint')*8.0 AS page_faults_kb
				,record
		FROM (	SELECT	TOP 1 timestamp, CONVERT (xml, record) AS record, cpu_ticks / (cpu_ticks/ms_ticks) as ts_now
				FROM sys.dm_os_ring_buffers orb cross apply sys.dm_os_sys_info osi
				WHERE ring_buffer_type = 'RING_BUFFER_SCHEDULER_MONITOR'
				AND record LIKE '%<SystemHealth>%'
				ORDER BY [timestamp] DESC
		) AS rd
) as t;

"
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_decimal)
				exec (@_sql);

				-- set @_ip
				select @_pcnt_kernel_mode = col_decimal from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [page_faults_kb] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and ( @output is null or exists (select * from @_tbl_output_columns where column_name = 'page_faults_kb') )
		begin
			delete from @_result;
			set @_sql =  "
SET QUOTED_IDENTIFIER ON;
SELECT page_faults_kb
FROM (
		SELECT	DATEADD (ms, -1 * (ts_now - [timestamp]), GETDATE()) AS event_time
				,DATEADD(mi, DATEDIFF(mi, getdate(), getutcdate()), DATEADD (ms, -1 * (ts_now - [timestamp]), GETDATE())) AS event_time_utc
				,100-record.value('(Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS system_cpu
				,record.value('(Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS sql_cpu
				,record.value('(Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS idle_system_cpu
				,record.value('(Record/SchedulerMonitorEvent/SystemHealth/UserModeTime)[1]', 'bigint')/10000 AS user_mode_time_ms
				,record.value('(Record/SchedulerMonitorEvent/SystemHealth/KernelModeTime)[1]', 'bigint')/10000 AS kernel_mode_time_ms
				,record.value('(Record/SchedulerMonitorEvent/SystemHealth/PageFaults)[1]', 'bigint')*8.0 AS page_faults_kb
				,record
		FROM (	SELECT	TOP 1 timestamp, CONVERT (xml, record) AS record, cpu_ticks / (cpu_ticks/ms_ticks) as ts_now
				FROM sys.dm_os_ring_buffers orb cross apply sys.dm_os_sys_info osi
				WHERE ring_buffer_type = 'RING_BUFFER_SCHEDULER_MONITOR'
				AND record LIKE '%<SystemHealth>%'
				ORDER BY [timestamp] DESC
		) AS rd
) as t;

"
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_decimal)
				exec (@_sql);

				-- set @_ip
				select @_page_faults_kb = col_decimal from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [blocked_counts] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and ( @output is null or exists (select * from @_tbl_output_columns where column_name = 'blocked_counts') )
		begin
			delete from @_result;
			set @_sql =  "
--SET QUOTED_IDENTIFIER ON;
select count(*) as blocked_counts --, max(wait_time)/1000 as wait_time_s
from sys.dm_exec_requests r with (nolock) 
where r.blocking_session_id <> 0
and wait_time >= ("+convert(varchar,@blocked_threshold_seconds)+"*1000) -- Over 60 seconds

"
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_int)
				exec (@_sql);

				-- set @_ip
				select @_blocked_counts = col_int from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [blocked_duration_max_seconds] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and ( @output is null or exists (select * from @_tbl_output_columns where column_name = 'blocked_duration_max_seconds') )
		begin
			delete from @_result;
			set @_sql =  "
--SET QUOTED_IDENTIFIER ON;
declare @_wait_time_s bigint = 0;

select @_wait_time_s = floor(max(wait_time)/1000) --,count(*) as blocked_counts
from sys.dm_exec_requests r with (nolock) 
where r.blocking_session_id <> 0
and wait_time >= ("+convert(varchar,@blocked_threshold_seconds)+"*1000) -- Over 60 seconds

select isnull(@_wait_time_s,0) as [blocked_duration_max_seconds];

"
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_bigint)
				exec (@_sql);

				-- set @_ip
				select @_blocked_duration_max_seconds = col_bigint from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [total_physical_memory_kb] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and ( @output is null or exists (select * from @_tbl_output_columns where column_name = 'total_physical_memory_kb') )
		begin
			delete from @_result;
			set @_sql =  "
--SET QUOTED_IDENTIFIER ON;
select	osm.total_physical_memory_kb
		--,osm.available_physical_memory_kb
		--,case when system_high_memory_signal_state = 1 then 'High' else 'Low' end as [Memory State]
		--,opm.physical_memory_in_use_kb
		--,opm.memory_utilization_percentage
from sys.dm_os_sys_memory osm, sys.dm_os_process_memory opm;

"
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_bigint)
				exec (@_sql);

				-- set @_ip
				select @_total_physical_memory_kb = col_bigint from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [available_physical_memory_kb] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and ( @output is null or exists (select * from @_tbl_output_columns where column_name = 'available_physical_memory_kb') )
		begin
			delete from @_result;
			set @_sql =  "
--SET QUOTED_IDENTIFIER ON;
select	--osm.total_physical_memory_kb
		osm.available_physical_memory_kb
		--,case when system_high_memory_signal_state = 1 then 'High' else 'Low' end as [Memory State]
		--,opm.physical_memory_in_use_kb
		--,opm.memory_utilization_percentage
from sys.dm_os_sys_memory osm, sys.dm_os_process_memory opm;

"
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_bigint)
				exec (@_sql);

				-- set @_ip
				select @_available_physical_memory_kb = col_bigint from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [system_high_memory_signal_state] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and ( @output is null or exists (select * from @_tbl_output_columns where column_name = 'system_high_memory_signal_state') )
		begin
			delete from @_result;
			set @_sql =  "
--SET QUOTED_IDENTIFIER ON;
select	--osm.total_physical_memory_kb
		--osm.available_physical_memory_kb
		case when system_high_memory_signal_state = 1 then 'High' else 'Low' end as [Memory State]
		--,opm.physical_memory_in_use_kb
		--,opm.memory_utilization_percentage
from sys.dm_os_sys_memory osm, sys.dm_os_process_memory opm;

"
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_varchar)
				exec (@_sql);

				-- set @_ip
				select @_system_high_memory_signal_state = col_varchar from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [physical_memory_in_use_kb] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and ( @output is null or exists (select * from @_tbl_output_columns where column_name = 'physical_memory_in_use_kb') )
		begin
			delete from @_result;
			set @_sql =  "
--SET QUOTED_IDENTIFIER ON;
select	--osm.total_physical_memory_kb
		--osm.available_physical_memory_kb
		--,case when system_high_memory_signal_state = 1 then 'High' else 'Low' end as [Memory State]
		opm.physical_memory_in_use_kb
		--,opm.memory_utilization_percentage
from sys.dm_os_sys_memory osm, sys.dm_os_process_memory opm;

"
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_decimal)
				exec (@_sql);

				-- set @_ip
				select @_physical_memory_in_use_kb = col_decimal from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [memory_grants_pending] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and ( @output is null or exists (select * from @_tbl_output_columns where column_name = 'memory_grants_pending') )
		begin
			delete from @_result;
			set @_sql =  "
--SET QUOTED_IDENTIFIER ON;
declare @object_name varchar(255);
set @object_name = (case when @@SERVICENAME = 'MSSQLSERVER' then 'SQLServer' else 'MSSQL$'+@@SERVICENAME end);

SELECT cntr_value
FROM sys.dm_os_performance_counters WITH (NOLOCK) 
WHERE 1=1
and [object_name] like (@object_name+':Memory Manager%')
AND counter_name = N'Memory Grants Pending'

"
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_int)
				exec (@_sql);

				-- set @_ip
				select @_memory_grants_pending = col_int from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [connection_count] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and ( @output is null or exists (select * from @_tbl_output_columns where column_name = 'connection_count') )
		begin
			delete from @_result;
			set @_sql =  "
--SET QUOTED_IDENTIFIER ON;
select count(*) as counts from sys.dm_exec_connections with (nolock)
"
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_int)
				exec (@_sql);

				-- set @_ip
				select @_connection_count = col_int from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [active_requests_count] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and ( @output is null or exists (select * from @_tbl_output_columns where column_name = 'active_requests_count') )
		begin
			delete from @_result;
			set @_sql =  "
SET NOCOUNT ON;
exec usp_active_requests_count;
"
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_int)
				exec (@_sql);

				-- set @_ip
				select @_active_requests_count = col_int from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [waits_per_core_per_minute] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and ( @output is null or exists (select * from @_tbl_output_columns where column_name = 'waits_per_core_per_minute') )
		begin
			delete from @_result;
			set @_sql =  "
SET NOCOUNT ON;
exec usp_waits_per_core_per_minute;
"
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_decimal)
				exec (@_sql);

				-- set @_ip
				select @_waits_per_core_per_minute = col_decimal from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [os_start_time_utc] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and ( @output is null or exists (select * from @_tbl_output_columns where column_name = 'os_start_time_utc') )
		begin
			delete from @_result;
			set @_sql = "select [os_start_time_utc] = DATEADD(mi, DATEDIFF(mi, getdate(), getutcdate()), dateadd(SECOND,-osi.ms_ticks/1000,GETDATE())) from sys.dm_os_sys_info as osi";
			
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_datetime)
				exec (@_sql);

				-- set @_ip
				select @_os_start_time_utc = col_datetime from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [cpu_count] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and ( @output is null or exists (select * from @_tbl_output_columns where column_name = 'cpu_count') )
		begin
			delete from @_result;
			set @_sql = "select osi.cpu_count /* osi.scheduler_count */ from sys.dm_os_sys_info as osi";
			
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_int)
				exec (@_sql);

				-- set @_ip
				select @_cpu_count = col_int from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [scheduler_count] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and ( @output is null or exists (select * from @_tbl_output_columns where column_name = 'scheduler_count') )
		begin
			delete from @_result;
			set @_sql = "select osi.scheduler_count from sys.dm_os_sys_info as osi";
			
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_int)
				exec (@_sql);

				-- set @_ip
				select @_scheduler_count = col_int from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [major_version_number] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and ( @output is null or exists (select * from @_tbl_output_columns where column_name = 'major_version_number') )
		begin
			delete from @_result;
			set @_sql = "
declare @server_major_version_number tinyint;
SET @server_major_version_number = CONVERT(tinyint, SERVERPROPERTY('ProductMajorVersion'))

if @server_major_version_number is null
begin
	;with t_versions as 
	( select CONVERT(varchar,SERVERPROPERTY('ProductVersion')) as ProductVersion
			 ,LEFT(CONVERT(varchar,SERVERPROPERTY('ProductVersion')), CHARINDEX('.',CONVERT(varchar,SERVERPROPERTY('ProductVersion')))-1) AS MajorVersion
	)
	select @server_major_version_number = MajorVersion from t_versions;
end

select	[@server_major_version_number] = @server_major_version_number;			
";
			
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_int)
				exec (@_sql);

				-- set @_ip
				select @_major_version_number = col_int from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- [minor_version_number] => Create SQL Statement to Execute
		if @_linked_server_failed = 0 and ( @output is null or exists (select * from @_tbl_output_columns where column_name = 'minor_version_number') )
		begin
			delete from @_result;
			set @_sql = "
declare @server_product_version varchar(20);
declare @server_major_version_number tinyint;
declare @server_minor_version_number smallint;

SET @server_product_version = CONVERT(varchar,SERVERPROPERTY('ProductVersion'));
SET @server_major_version_number = CONVERT(tinyint, SERVERPROPERTY('ProductMajorVersion'));

if @server_major_version_number is null
begin
	;with t_versions as 
	( select CONVERT(varchar,SERVERPROPERTY('ProductVersion')) as ProductVersion
			 ,LEFT(CONVERT(varchar,SERVERPROPERTY('ProductVersion')), CHARINDEX('.',CONVERT(varchar,SERVERPROPERTY('ProductVersion')))-1) AS MajorVersion
	)
	select @server_major_version_number = MajorVersion from t_versions;
end

declare @server_minor_version_number_intermediate varchar(20);
set @server_minor_version_number_intermediate = REPLACE(@server_product_version,CONVERT(varchar,@server_major_version_number)+'.'+CONVERT(varchar, SERVERPROPERTY('ProductMinorVersion'))+'.','');

if(@server_minor_version_number_intermediate is null)
begin
	;with t_versions as
	( select replace(@server_product_version,CONVERT(varchar,@server_major_version_number)+'.','') as VrsnString )
	select @server_minor_version_number_intermediate = REPLACE(@server_product_version,CONVERT(varchar,@server_major_version_number)+'.'+LEFT(VrsnString,CHARINDEX('.',VrsnString)-1)+'.','')
	from t_versions;
end

set @server_minor_version_number = left(@server_minor_version_number_intermediate,charindex('.',@server_minor_version_number_intermediate)-1);

SELECT	[@server_minor_version_number] = @server_minor_version_number
";
			
			-- Decorate for remote query if LinkedServer
			if @_isLocalHost = 0
				set @_sql = 'select * from openquery(' + QUOTENAME(@_srv_name) + ', "'+ @_sql + '")';
		
			begin try
				insert @_result (col_int)
				exec (@_sql);

				-- set @_ip
				select @_minor_version_number = col_int from @_result;
			end try
			begin catch
				-- print @_sql;
				print char(10)+char(13)+'Error occurred while executing below query on '+quotename(@_srv_name)+char(10)+'     '+@_sql;
				print  '	ErrorNumber => '+convert(varchar,ERROR_NUMBER());
				print  '	ErrorSeverity => '+convert(varchar,ERROR_SEVERITY());
				print  '	ErrorState => '+convert(varchar,ERROR_STATE());
				--print  '	ErrorProcedure => '+ERROR_PROCEDURE();
				print  '	ErrorLine => '+convert(varchar,ERROR_LINE());
				print  '	ErrorMessage => '+ERROR_MESSAGE();
			end catch
		end


		-- Populate all details for single server inside loop
		if @_linked_server_failed = 0
		begin
			insert #server_details 
			(	[srv_name], [at_server_name], [machine_name], [server_name], [ip], [domain], [host_name], [product_version], [edition], [sqlserver_start_time_utc], [os_cpu], [sql_cpu], 
				[pcnt_kernel_mode], [page_faults_kb], [blocked_counts], [blocked_duration_max_seconds], [total_physical_memory_kb], 
				[available_physical_memory_kb], [system_high_memory_signal_state], [physical_memory_in_use_kb], [memory_grants_pending], 
				[connection_count], [active_requests_count], [waits_per_core_per_minute], [os_start_time_utc], [cpu_count], 
				[scheduler_count], [major_version_number], [minor_version_number]
			)
			select	[srv_name] = @_srv_name
					,[@@servername] = @_at_server_name
					,[machine_name] = @_machine_name
					,[server_name] = @_server_name
					,[ip] = @_ip
					,[domain] = @_domain
					,[host_name] = @_host_name
					,[product_version] = @_product_version
					,[edition] = @_edition
					,[sqlserver_start_time_utc] = @_sqlserver_start_time_utc
					,[os_cpu] = @_os_cpu
					,[sql_cpu] = @_sql_cpu
					,[pcnt_kernel_mode] = @_pcnt_kernel_mode
					,[page_faults_kb] = @_page_faults_kb
					,[blocked_counts] = @_blocked_counts
					,[blocked_duration_max_seconds] = @_blocked_duration_max_seconds
					,[total_physical_memory_kb] = @_total_physical_memory_kb
					,[available_physical_memory_kb] = @_available_physical_memory_kb
					,[system_high_memory_signal_state] = @_system_high_memory_signal_state
					,[physical_memory_in_use_kb] = @_physical_memory_in_use_kb
					,[memory_grants_pending] = @_memory_grants_pending
					,[connection_count] = @_connection_count
					,[active_requests_count] = @_active_requests_count
					,[waits_per_core_per_minute] = @_waits_per_core_per_minute
					,[os_start_time_utc] = @_os_start_time_utc
					,[cpu_count] = @_cpu_count
					,[scheduler_count] = @_scheduler_count
					,[major_version_number] = @_major_version_number
					,[minor_version_number] = @_minor_version_number
		end

		FETCH NEXT FROM cur_servers INTO @_srv_name;
	END
	
	
	CLOSE cur_servers;  
	DEALLOCATE cur_servers;

	-- Return all server details
	if @result_to_table is null
	begin
		set @_sql = "select "+(case when @output is null then "*" else @output end)+" from #server_details;";
		print "@result_to_table not supplied. So returning resultset."
	end
	else
	begin
		declare @table_name nvarchar(125);
		set @result_to_table = ltrim(rtrim(@result_to_table));

		-- set appropriate table name
		if(left(@result_to_table,1) = '#') -- temp table
			set @table_name = 'tempdb..'+@result_to_table
		else
		begin -- physical table
			if CHARINDEX('.','dbo.xyz') > 0
				set @table_name = @result_to_table;
			else
				set @table_name = 'dbo.'+@result_to_table;
		end

		-- delete table data
		if object_id(@table_name) is not null
		begin
			set @_sql = "delete from "+@table_name;
			exec (@_sql);
		end

		if object_id(@table_name) is not null and @output is null
		begin
			set @_sql = "insert "+@result_to_table+" select * from #server_details;";
			print "@result_to_table '"+@result_to_table+"' exist, but no columns specified."
		end
		else if object_id(@table_name) is not null and @output is not null
		begin
			set @_sql = "insert "+@result_to_table+" ("+@output+") select "+@output+" from #server_details;";
			print "@result_to_table '"+@result_to_table+"' exist, and columns specified."
		end
		else
		begin
			set @_sql = "select "+(case when @output is null then "*" else @output end)+" into "+@result_to_table+" from #server_details;";
			print "@result_to_table '"+@result_to_table+"' does exist, so creating same."
			print @_sql;
		end
	end

	exec (@_sql);

	print 'Transaction Counts => '+convert(varchar,@@trancount);
END
set quoted_identifier on;
GO

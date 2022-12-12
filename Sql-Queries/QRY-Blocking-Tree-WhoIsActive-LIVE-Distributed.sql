USE DBA;
go

declare @sql nvarchar(max);
declare @params nvarchar(max);
declare @sql_instance varchar(255);
declare @perfmon_host_name varchar(255);
declare @start_time_utc datetime2;
declare @end_time_utc datetime2;

set @sql_instance = 'SqlPractice';
set @perfmon_host_name = 'SQLPRACTICE';
set @start_time_utc = dateadd(minute,-30,getutcdate());
set @end_time_utc = GETUTCDATE();
set @params = N'@perfmon_host_name varchar(255), @start_time_utc datetime2, @end_time_utc datetime2';

set quoted_identifier off;
set @sql = "
set nocount on;
-- Get Blocking Tree
if exists (select * from dbo.WhoIsActive where (collection_time between DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), @start_time_utc) and DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), @end_time_utc)) and (blocking_session_id is not null or replace(blocked_session_count,',','') > 0) )
begin
	;WITH T_BLOCKERS AS
	(
		-- Find block Leaders
		SELECT	datediff(MILLISECOND, start_time, getdate()) as duration_ms,
				[collection_time], [session_id], 
				[sql_text] = REPLACE(REPLACE(REPLACE(REPLACE(CAST(COALESCE([sql_command],[sql_text]) AS VARCHAR(MAX)),char(13),''),CHAR(10),''),'<?query --',''),'--?>',''), 
				command = additional_info.value('(/additional_info/command_type)[1]','varchar(125)'), [login_name], wait_info, [blocking_session_id], [blocked_session_count] = replace(blocked_session_count,',',''),
				[status], open_tran_count, [host_name], [database_name], [program_name], tasks, granted_memory,
				r.CPU, r.used_memory, r.[tempdb_allocations], r.[tempdb_current], r.[reads], r.[writes], r.[physical_io],
				[LEVEL] = CAST (REPLICATE ('0', 4-LEN (CAST (r.session_id AS VARCHAR))) + CAST (r.session_id AS VARCHAR) AS VARCHAR (1000))
				,[head_blocker] = session_id
		FROM	dbo.WhoIsActive AS r with (nolock)
		WHERE	 (collection_time between DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), @start_time_utc) and DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), @end_time_utc))
		and (r.blocking_session_id IS NULL AND replace(blocked_session_count,',','') > 0)
		--	
		UNION ALL
		--
		SELECT	datediff(MILLISECOND, r.start_time, getdate()) as duration_ms,
				r.[collection_time], r.[session_id], 
				[sql_text] = REPLACE(REPLACE(REPLACE(REPLACE(CAST(COALESCE(r.[sql_command],r.[sql_text]) AS VARCHAR(MAX)),char(13),''),CHAR(10),''),'<?query --',''),'--?>',''), 
				command = r.additional_info.value('(/additional_info/command_type)[1]','varchar(125)'), r.[login_name], r.wait_info, r.[blocking_session_id], [blocked_session_count] = replace(r.blocked_session_count,',',''),
				r.[status], r.open_tran_count, r.[host_name], r.[database_name], r.[program_name], r.tasks, r.granted_memory,
				r.CPU, r.used_memory, r.[tempdb_allocations], r.[tempdb_current], r.[reads], r.[writes], r.[physical_io],
				CAST (B.LEVEL + RIGHT (CAST ((1000 + r.session_id) AS VARCHAR (100)), 4) AS VARCHAR (1000)) AS LEVEL
				,[head_blocker] = case when B.[head_blocker] is null then B.session_id else B.[head_blocker] end
		FROM	dbo.WhoIsActive AS r with (nolock)
		INNER JOIN 
				T_BLOCKERS AS B
			ON	r.collection_time = B.collection_time
			AND	r.blocking_session_id = B.session_id
		WHERE	 r.blocking_session_id <> r.session_id
	)
	SELECT	[collection_time] = DATEADD(mi, DATEDIFF(mi, getdate(), getutcdate()), [collection_time]), 
			[ddd hh:mm:ss.mss] = right('0000'+convert(varchar, duration_ms/86400000),3)+ ' '+convert(varchar,dateadd(MILLISECOND,duration_ms,'1900-01-01 00:00:00'),114),
			[session_id], 
			[BLOCKING_TREE] = N'    ' + REPLICATE (N'|         ', LEN (LEVEL)/4 - 1) 
							+	CASE	WHEN (LEN(LEVEL)/4 - 1) = 0
										THEN 'HEAD -  '
										ELSE '|------  ' 
								END
							+	CAST (r.session_id AS NVARCHAR (10)) + N' ' + ISNULL((CASE WHEN LEFT(ISNULL(r.[sql_text],''),1) = '(' THEN SUBSTRING(ISNULL(r.[sql_text],''),CHARINDEX('exec',ISNULL(r.[sql_text],'')),LEN(ISNULL(r.[sql_text],'')))  ELSE ISNULL(r.[sql_text],'') END),''),
			[blocking_session_id], [blocked_session_count] = case when [blocked_session_count] = 0 then null else [blocked_session_count] end, [login_name], [program_name], [host_name],
			tasks,
			--[sql_commad] = CONVERT(XML, '<?query -- '+char(13)
			--				+ (CASE WHEN LEFT([sql_text],1) = '(' THEN SUBSTRING([sql_text],CHARINDEX('exec',[sql_text]),LEN([sql_text]))  ELSE [sql_text] END)
			--				+ char(13)+'--?>')
			command, [database_name], wait_info, status, 
			r.open_tran_count, r.CPU, [used_memory_kb] = (r.used_memory*8.0), [reads_kb] = (r.[reads]*8.0), r.[writes] --, r.[physical_io]
			,[tempdb_allocations_kb] = tempdb_allocations*8.0, tempdb_current_kb = tempdb_current*8.0, granted_memory_kb = granted_memory * 8.0
	FROM	T_BLOCKERS AS r
	ORDER BY collection_time, LEVEL;
end
else
  select 'No Blocking Found for Time Window' as [No Result]
"
set quoted_identifier on;

--if (@sql_instance = SERVERPROPERTY('SERVERNAME'))
--if (0 = 1)
  exec dbo.sp_executesql @sql , @params, @perfmon_host_name, @start_time_utc, @end_time_utc;
--else
--  exec [SqlPractice].[DBA].dbo.sp_executesql @sql , @params, @perfmon_host_name, @start_time_utc, @end_time_utc;
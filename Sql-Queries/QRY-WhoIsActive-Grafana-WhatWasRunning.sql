declare @sql nvarchar(max);
declare @params nvarchar(max);
declare @sql_instance varchar(255);
declare @perfmon_host_name varchar(255);
declare @start_time_utc datetime2;
declare @end_time_utc datetime2;
declare @duration int;

set @sql_instance = 'SqlPractice';
set @perfmon_host_name = 'SQLPRACTICE';
set @start_time_utc = '2022-12-12T11:42:27Z';
set @end_time_utc = '2022-12-12T13:42:27Z';
set @duration = case when ltrim(rtrim('15')) <> '' then 15 else 0 end; 
set @params = N'@perfmon_host_name varchar(255), @start_time_utc datetime2, @end_time_utc datetime2, @duration int';

set quoted_identifier off;
set @sql = "
set nocount on;
if exists ( select * from dbo.WhoIsActive w with (nolock)
            where w.collection_time = (select max(i.collection_time) from dbo.WhoIsActive i) 
            and datediff(minute,start_time,collection_time) >= @duration )
begin
  ;with t_WhoIsActive as (
    select [collection_time], w.session_id, /* = convert(varchar,w.collection_time,120) */
        w.program_name, w.login_name, w.database_name, w.host_name, w.status, w.CPU, w.granted_memory, w.used_memory, w.open_tran_count, w.wait_info,
        sql_command = case when w.sql_command is not null then left(replace(replace(convert(nvarchar(max),w.sql_command),char(13)+char(10),''),'<?query --',''),150)
                  else left(replace(replace(convert(nvarchar(max),w.sql_text),char(13)+char(10),''),'<?query --',''),150) end,
        w.blocked_session_count, [duration_ms] = datediff(MILLISECOND, start_time, getdate()),
        w.blocking_session_id, w.reads, w.writes, w.tempdb_allocations, w.tempdb_current, w.tasks, w.percent_complete, start_time = convert(varchar,w.start_time,120)
    from dbo.WhoIsActive w with (nolock)
    where w.collection_time = (select max(i.collection_time) from dbo.WhoIsActive i)
    and datediff(minute,start_time,collection_time) >= @duration
  )
  select  [collection_time] = DATEADD(mi, DATEDIFF(mi, getdate(), getutcdate()), [collection_time]), w.session_id,
          [ddd hh:mm:ss.mss] = right('0000'+convert(varchar, duration_ms/86400000),3)+ ' '+convert(varchar,dateadd(MILLISECOND,duration_ms,'1900-01-01 00:00:00'),114), 
          w.program_name, w.login_name, w.database_name, w.host_name, w.status, w.CPU, 
          granted_memory_kb = (w.granted_memory * 8.0), w.open_tran_count, w.wait_info, w.sql_command, w.blocked_session_count, 
          w.blocking_session_id, [reads_kb] = (w.[reads]*8.0), w.writes, [tempdb_allocations_kb] = (w.tempdb_allocations*8.0), 
          tempdb_current_kb = (tempdb_current*8.0), w.tasks, w.percent_complete, [used_memory_kb] = (w.used_memory*8.0),
          start_time = DATEADD(mi, DATEDIFF(mi, getdate(), getutcdate()), [start_time])
			    
  from t_WhoIsActive w
  order by w.collection_time DESC, w.start_time ASC
end
ELSE
  select 'No long running query found for time window' as [No Result]
"
set quoted_identifier on;

--if (@sql_instance = SERVERPROPERTY('SERVERNAME'))
if (0 = 1)
  exec dbo.sp_executesql @sql , @params, @perfmon_host_name, @start_time_utc, @end_time_utc, @duration;
else
  exec [SqlPractice].[DBA].dbo.sp_executesql @sql , @params, @perfmon_host_name, @start_time_utc, @end_time_utc, @duration;
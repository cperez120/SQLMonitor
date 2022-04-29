use DBA
go

declare @start_time datetime = dateadd(minute,-60,getdate());
declare @end_time datetime = getdate();

select w.collection_time, w.login_name, w.blocked_session_count, *
from dbo.WhoIsActive w
where (w.collection_time between @start_time and @end_time)
and (w.blocking_session_id is null and blocked_session_count > 0) -- get lead blockers only


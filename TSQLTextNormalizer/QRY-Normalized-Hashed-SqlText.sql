use DBA
go

/*
	1) Create function 
			\SQLMonitor\DDLs\SCH-fn_get_hash_for_string.sql in [DBA] database
	2) Create CLR function 
			\SQLMonitor\TSQLTextNormalizer\SCH-Assembly-[SQLMonitorAssembly].sql
*/
go

select hs.sqlsig, counts = count(rc.session_id)over(partition by hs.sqlsig), *
from dbo.resource_consumption rc
outer apply (select sqlsig = hs.varbinary_value
			from dbo.fn_get_hash_for_string(dbo.normalized_sql_text(rc.sql_text,150,0)) hs  
			) hs
where rc.event_time >= dateadd(hour,-24,getdate())
order by rc.start_time, rc.event_time
go

-- dbo.fn_get_hash_for_string('EXEC dbo.usp_run_WhoIsActive @recipients = ''sqlagentservice@gmail.com'';')
-- select sqlsig = DBA.dbo.normalized_sql_text('exec sp_WhoIsActive 110',150,0)

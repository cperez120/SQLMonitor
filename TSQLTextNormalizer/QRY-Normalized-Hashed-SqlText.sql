use [DBA]
go

/*
	1) Create function 
			\SQLMonitor\DDLs\SCH-fn_get_hash_for_string.sql in [DBA] database
	2) Create CLR function 
			\SQLMonitor\TSQLTextNormalizer\SCH-Assembly-[SQLMonitorAssembly].sql
	3) Create procedure 
			\SQLMonitor\DDLs\SCH-usp_collect_xevents_resource_consumption_hashed
	4) Change Job [(dba) Collect-XEvents] to use [usp_collect_xevents_resource_consumption_hashed]
*/
go

select top 100 hs.sqlsig, counts = count(rc.session_id)over(partition by hs.sqlsig), *
--update rc set query_hash = hs.sqlsig
from dbo.resource_consumption rc
outer apply (select sqlsig = hs.varbinary_value
			from dbo.fn_get_hash_for_string(dbo.normalized_sql_text(rc.sql_text,150,0)) hs  
			) hs
where 1=1
and rc.query_hash is null
and rc.event_time >= dateadd(hour,-24,getdate())
order by rc.start_time, rc.event_time
go

-- dbo.fn_get_hash_for_string('EXEC dbo.usp_run_WhoIsActive @recipients = ''sqlagentservice@gmail.com'';')
-- select sqlsig = DBA.dbo.normalized_sql_text('exec sp_WhoIsActive 110',150,0)
go

select *
from dbo.resource_consumption rc
where 1=1
and rc.event_time >= dateadd(MINUTE,-10,getdate())
go

/*	Update existing records with Hash */
while exists (select 1 from dbo.resource_consumption where query_hash is null and result = 'OK')
begin
	update top (3000) rc set query_hash = hs.sqlsig
	from dbo.resource_consumption rc
	cross apply (select sqlsig = hs.varbinary_value
				from dbo.fn_get_hash_for_string(dbo.normalized_sql_text(rc.sql_text,150,0)) hs  
				) hs
	where 1=1
	and result = 'OK'
	and rc.query_hash is null;
end
go

DECLARE @sql nvarchar(max)

select @sql = REPLACE(REPLACE(sm.definition, 'path, ',''), 'CREATE VIEW', 'ALTER VIEW')
from sys.sql_modules sm join sys.objects o on sm.object_id = o.object_id
where o.name = 'vw_performance_counters';

--print @sql
exec (@sql)




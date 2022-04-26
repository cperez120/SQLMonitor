use [DBA]
go

exec sp_rename 'dbo.performance_counters', 'performance_counters_old'
go

exec sp_rename 'dbo.os_task_list', 'os_task_list_old'
go

--drop synonym dbo.performance_counters
create synonym dbo.performance_counters for [OtherSqlInstance].[DBA].dbo.performance_counters
go
--drop synonym dbo.os_task_list
create synonym dbo.os_task_list for [OtherSqlInstance].[DBA].[dbo].[os_task_list]
go

/* 
Now modify the view mentioned in DDLs\All Scripts 
dbo.vw_performance_counters
*/
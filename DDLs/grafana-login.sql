use [master]
go
if not exists (select * from sys.syslogins where name = 'grafana')
	create login [grafana] with password=N'grafana', default_database=[DBA], check_expiration=off, check_policy=off
go
if not exists (select * from sys.sysusers where name = 'grafana')
	create user [grafana] for login [grafana]
go
grant view any definition to [grafana]
go
grant view server state to [grafana]
go
if object_id('dbo.SqlServerVersions') is not null
	grant select on object::dbo.SqlServerVersions to [grafana]
go

use [DBA]
go
if not exists (select * from sys.sysusers where name = 'grafana')
	create user [grafana] for login [grafana]
go
alter role [db_datareader] add member [grafana]
go
grant view database state to [grafana]
go
if OBJECT_ID('dbo.usp_extended_results') is not null
	grant execute on object::dbo.usp_extended_results to [grafana]
go
if OBJECT_ID('dbo.sp_WhatIsRunning') is not null
	grant execute on object::dbo.sp_WhatIsRunning to [public]
go
if OBJECT_ID('dbo.resource_consumption') is not null
	grant select on object::dbo.resource_consumption to [grafana]
go
if OBJECT_ID('dbo.usp_GetAllServerInfo') is not null
	grant execute on object::dbo.usp_GetAllServerInfo TO [grafana]
go

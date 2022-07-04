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
	exec ('grant select on object::dbo.SqlServerVersions to [grafana]')
go

use [DBA]
if exists (select * from sys.sysusers where name = 'grafana')
	drop user [grafana];
go
use [DBA]
	create user [grafana] for login [grafana]
go
use [DBA]
alter role [db_datareader] add member [grafana]
go
use [DBA]
grant view database state to [grafana]
go
use [DBA]
if OBJECT_ID('dbo.usp_extended_results') is not null
	exec ('grant execute on object::dbo.usp_extended_results to [grafana]')
go
use [DBA]
if OBJECT_ID('dbo.sp_WhatIsRunning') is not null
	exec ('grant execute on object::dbo.sp_WhatIsRunning to [public]')
go
use [DBA]
if OBJECT_ID('dbo.resource_consumption') is not null
	exec ('grant select on object::dbo.resource_consumption to [grafana]')
go
use [DBA]
if OBJECT_ID('dbo.usp_GetAllServerInfo') is not null
	exec ('grant execute on object::dbo.usp_GetAllServerInfo TO [grafana]')
go

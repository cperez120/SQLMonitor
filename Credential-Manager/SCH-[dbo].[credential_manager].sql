IF DB_NAME() = 'master'
	raiserror ('Kindly execute all queries in [DBA] database', 20, -1) with log;
go

use DBA
go

-- alter table dbo.credential_manager set (system_versioning = off);
-- drop table dbo.credential_manager
create table dbo.credential_manager
(	server_ip char(15) not null,
	server_name varchar(125) null,
	[user_name] varchar(125) not null,
	[password_hash] varbinary(256) not null,
	salt varbinary(125) null,
	is_sql_user bit not null default 0,
	is_rdp_user bit not null default 0,
	created_date datetime2 not null default getdate(),
	created_by varchar(125) not null default suser_name(),
	updated_date datetime2 not null default getdate(),
	updated_by varchar(125) not null default suser_name(),
	delegate_login_01 varchar(125) null,
	delegate_login_02 varchar(125) null,
	remarks nvarchar(2000)
	,constraint pk_credential_manager primary key clustered (server_ip, [user_name])

	,valid_from datetime2 generated always as row start hidden NOT NULL
    ,valid_to datetime2 generated always as row end hidden NOT NULL
    ,period for system_time (valid_from,valid_to)
)
with (system_versioning = on (HISTORY_TABLE = dbo.credential_manager_history))
go
create nonclustered index uq__server_name__user_name on dbo.credential_manager (server_name, [user_name])
go

-- drop table dbo.credential_manager_backup
--select * into dbo.credential_manager_backup from dbo.credential_manager
--insert dbo.credential_manager
--select * from dbo.credential_manager_backup
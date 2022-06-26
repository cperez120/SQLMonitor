IF DB_NAME() = 'master'
	raiserror ('Kindly execute all queries in [DBA] database', 20, -1) with log;
go

use DBA
go

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
	remarks nvarchar(2000),
	dummy as 1/0,
	constraint pk_credential_manager primary key clustered (server_ip, [user_name])
);
go


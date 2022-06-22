;with t_servers as (
	select server as ServerName, friendly_name, rdp_credential, sql_credential from [SQLDBATools].[dbo].[sdt_server_inventory] i 
	where is_active = 1 and monitoring_enabled = 1 and i.server in ('')
	union all
	select friendly_name as ServerName, friendly_name, rdp_credential, sql_credential from [SQLDBATools].[dbo].[sdt_server_inventory] i 
	where is_active = 1 and monitoring_enabled = 1 and  i.friendly_name in ('localhost')
	union all
	select sql_instance as ServerName, friendly_name, rdp_credential, sql_credential from [SQLDBATools].[dbo].[sdt_server_inventory] i 
	where is_active = 1 and monitoring_enabled = 1 and  i.sql_instance in ('')
	union all
	select ipv4 as ServerName, friendly_name, rdp_credential, sql_credential from [SQLDBATools].[dbo].[sdt_server_inventory] i 
	where is_active = 1 and monitoring_enabled = 1 and  i.ipv4 in ('SomeServerIP')
)
select i.ServerName, i.friendly_name, rdp_credential_username = i.rdp_credential, sql_credential_username = i.sql_credential
		,rdp_credential_password = crd_rdp.password
		,sql_credential_password = crd_sql.password
from t_servers i
outer apply (select top 1 server_ip, server_name, [user_name], is_sql_user, is_rdp_user, 
					password_hash, [password] = cast(DecryptByPassPhrase(cast(salt as varchar),password_hash ,1, server_ip) as varchar),
					salt, salt_raw = cast(salt as varchar),	created_date, created_by, updated_date, updated_by, 
					delegate_login_01, delegate_login_02, remarks 
			from dbo.credential_manager crd
			where crd.user_name = i.rdp_credential
			order by (case when server_ip is not null then 1 else 2 end) asc
			) crd_rdp
outer apply (select top 1 server_ip, server_name, [user_name], is_sql_user, is_rdp_user, 
					password_hash, [password] = cast(DecryptByPassPhrase(cast(salt as varchar),password_hash ,1, server_ip) as varchar),
					salt, salt_raw = cast(salt as varchar),	created_date, created_by, updated_date, updated_by, 
					delegate_login_01, delegate_login_02, remarks 
			from dbo.credential_manager crd
			where crd.user_name = i.sql_credential
			order by (case when server_ip is not null then 1 else 2 end) asc
			) crd_sql
go

alter table [dbo].[sdt_server_inventory]
	add availability_zone varchar(125) null

insert dbo.sdt_server_inventory
(server, friendly_name, sql_instance, ipv4, stability, priority)
select	server = '', 
		friendly_name = '', 
		sql_instance = '', 
		ipv4 = '',
		stability = 'PROD', 
		priority = 1
go

update dbo.sdt_server_inventory
set rdp_credential = ''
	,sql_credential = ''
where friendly_name = ''



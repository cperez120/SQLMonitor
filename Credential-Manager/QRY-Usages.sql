IF DB_NAME() = 'master'
	raiserror ('Kindly execute all queries in [DBA] database', 20, -1) with log;
go

use DBA
go

-- Check all Logins
select server_ip, server_name, [user_name], is_sql_user, is_rdp_user, password_hash, salt, 
created_date, created_by, updated_date, updated_by, delegate_login_01, delegate_login_02, remarks 
from dbo.credential_manager
go


/* Insert Credentials */
exec dbo.usp_add_credential
			@server_ip = '*',
			--@server_name = '<server_name>',
			@user_name = 'Lab\SQLServices',
			@password_string = 'Pa$$w0rd',
			--@passphrase_string = '421',
			--@is_sql_user = 1,
			--@is_rdp_user = 1,
			--@save_passphrase = 1,
			@remarks = 'DBA Service Account';
go

/* Fetch Credentials */
declare @password varchar(256);
exec dbo.usp_get_credential 
		--@server_ip = '*',
		--@user_name = 'Lab\SQLServices',
		@password = @password output;
select @password as [@password];
go


/* Get All Credential for Specific Server */
declare @server_ip char(15) = '*'
select server_ip, server_name, [user_name], is_sql_user, is_rdp_user, 
		password_hash, [password] = cast(DecryptByPassPhrase(cast(salt as varchar),password_hash ,1, isnull(@server_ip,server_ip)) as varchar),
		salt, salt_raw = cast(salt as varchar),	created_date, created_by, updated_date, updated_by, 
		delegate_login_01, delegate_login_02, remarks 
from dbo.credential_manager
where @server_ip is null or server_ip = @server_ip
go


/* Get All Credentials */
select server_ip, server_name, [user_name], is_sql_user, is_rdp_user, 
		password_hash, [password] = cast(DecryptByPassPhrase(cast(salt as varchar),password_hash ,1, server_ip) as varchar),
		salt, salt_raw = cast(salt as varchar),	created_date, created_by, updated_date, updated_by, 
		delegate_login_01, delegate_login_02, remarks 
from dbo.credential_manager
go
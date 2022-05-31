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

--drop procedure dbo.usp_add_credential
create or alter procedure dbo.usp_add_credential
	@server_ip char(15), 
	@server_name varchar(125) = null, 
	@user_name varchar(125), 
	@password_string varchar(256),
	@passphrase_string varchar(125) = null,
	@is_sql_user bit = 0,
	@is_rdp_user bit = 0,
	@save_passphrase bit = 1,
	@delegate_login_01 varchar(125) = null,
	@delegate_login_02 varchar(125) = null,
	@remarks nvarchar(2000) = null
with  encryption
as
begin
	if @save_passphrase = 0 and @passphrase_string is null
		throw 50000, 'Kindly provide passphrase_string.', 1;
	else
	begin
		-- If salt is null, assign one randomly
		if @passphrase_string is null
			set @passphrase_string = convert(varchar(125),100000+abs(checksum(NEWID()))%100000);
	end
	
	insert dbo.credential_manager
	(server_ip, server_name, [user_name], password_hash, salt, is_sql_user, is_rdp_user, delegate_login_01, delegate_login_02, remarks)
	select server_ip = @server_ip, server_name = @server_name, [user_name] = @user_name,
			password_hash = EncryptByPassPhrase(@passphrase_string, @password_string, 1, @server_ip),
			salt = case when @save_passphrase = 0 then null else convert(varbinary(125),@passphrase_string) end,
			is_sql_user = @is_sql_user, is_rdp_user = @is_rdp_user, @delegate_login_01, @delegate_login_02, remarks = @remarks;
	

	if @@ROWCOUNT > 0
		select 'Credential Saved.' as [result];
end
go

exec DBA.dbo.usp_add_credential
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


--drop procedure dbo.usp_add_credential
create or alter procedure dbo.usp_get_credential
	@server_ip char(15) = null, 
	@server_name varchar(125) = null, 
	@user_name varchar(125) = null,
	@passphrase_string varchar(125) = null,
	@password varchar(256) = null output
with  encryption
as
begin
	set nocount on;
	if (@server_ip is null and @user_name is null and @server_name is null) and (IS_SRVROLEMEMBER('SYSADMIN') <> 1)
		throw 50000, 'Kindly provide both server_ip/server_name or user_name.', 1;

	if IS_SRVROLEMEMBER('SYSADMIN') <> 1
		print 'Since caller is not a sysadmin, Only look for credentials created/updated by caller, or caller is delegate.'

	if object_id('tempdb..#matched_credentials') is not null
		drop table #matched_credentials;
	select server_ip, server_name, [user_name], is_sql_user, is_rdp_user, 
			password_hash, --[password] = cast(DecryptByPassPhrase(cast(salt as varchar),password_hash ,1, @server_ip) as varchar),
			salt, --salt_raw = cast(salt as varchar),		
			created_date, created_by, updated_date, updated_by, 
			delegate_login_01, delegate_login_02, remarks
	into #matched_credentials
	from dbo.credential_manager
	where (@server_ip is null or server_ip = @server_ip)
	and (@server_name is null or server_name = @server_name)
	and (@user_name is null or [user_name] = @user_name)
	and (	(IS_SRVROLEMEMBER('SYSADMIN') = 1)
		or	(created_by = SUSER_NAME() or updated_by = SUSER_NAME() or delegate_login_01 = SUSER_NAME() or delegate_login_02 = SUSER_NAME())
		);

	if(@passphrase_string is not null) and (select count(*) from #matched_credentials) > 1
		throw 50000, 'More than one credentials found. Kindly provide both server_ip and user_name to narrow down credential search.', 1;

	if IS_SRVROLEMEMBER('SYSADMIN') <> 1 and (select count(*) from #matched_credentials) > 1
		throw 50000, 'More than one credentials found. Kindly provide both server_ip and user_name to narrow down credential search.', 1;
	
	if exists (select 1 from #matched_credentials)
	begin
		if (select count(*) from #matched_credentials) = 1
		begin
			print 'exact one match found. Decrypting password, and storing to output variable..';
			select @password = case when @passphrase_string is null 
										then cast(DecryptByPassPhrase(cast(salt as varchar),password_hash ,1, isnull(@server_ip,server_ip)) as varchar)
										else cast(DecryptByPassPhrase(@passphrase_string,password_hash ,1, isnull(@server_ip,server_ip)) as varchar)
										end
			from #matched_credentials
		end
		else
		begin
			select server_ip, server_name, [user_name], is_sql_user, is_rdp_user,
				[password] = case when @passphrase_string is null 
									then cast(DecryptByPassPhrase(cast(salt as varchar),password_hash ,1, @server_ip) as varchar)
									else cast(DecryptByPassPhrase(@passphrase_string,password_hash ,1, @server_ip) as varchar)
									end,
				created_date, created_by, updated_date, updated_by, remarks
			from #matched_credentials
		end
	end
	else
		throw 50000, 'No matching credentials found.', 1;
end
go

-- Check all Logins
select server_ip, server_name, [user_name], is_sql_user, is_rdp_user, password_hash, salt, 
created_date, created_by, updated_date, updated_by, delegate_login_01, delegate_login_02, remarks 
from dbo.credential_manager
go

-- Fetch password
declare @password varchar(256);
exec DBA.dbo.usp_get_credential 
		--@server_ip = '*',
		--@user_name = 'Lab\SQLServices',
		@password = @password output;
select @password as [@password];
go


/*
declare @server_ip char(15) = '*'
select server_ip, server_name, [user_name], is_sql_user, is_rdp_user, 
		password_hash, [password] = cast(DecryptByPassPhrase(cast(salt as varchar),password_hash ,1, @server_ip) as varchar),
		salt, salt_raw = cast(salt as varchar),		
		created_date, created_by, updated_date, updated_by, remarks 
from dbo.credential_manager
where server_ip = @server_ip
go
*/
use DBA
go

if not exists (select * from sys.columns c where c.object_id = OBJECT_ID('dbo.instance_details') and c.name = 'collector_powershell_jobs_server')
begin
	alter table dbo.instance_details
		add [collector_tsql_jobs_server] varchar(255) null default convert(varchar,serverproperty('MachineName')),
		[collector_powershell_jobs_server] varchar(255) null default convert(varchar,serverproperty('MachineName')),
		[data_destination_sql_instance] varchar(255) null default convert(varchar,serverproperty('MachineName'))
end
go

if exists (select * from dbo.instance_details where [collector_powershell_jobs_server] is null)
begin
	declare @sql nvarchar(max);
	set @sql = '
	update id set [collector_tsql_jobs_server] = sql_instance
				,[collector_powershell_jobs_server] = coalesce([collector_powershell_jobs_server],collector_sql_instance,sql_instance)
				,[data_destination_sql_instance] = coalesce([data_destination_sql_instance],sql_instance)
	from dbo.instance_details id;
	'
	exec (@sql);
end
go

if exists (select * from sys.columns c where c.object_id = OBJECT_ID('dbo.instance_details') and c.name = 'collector_sql_instance')
begin
	declare @constraint_name nvarchar(255);
	declare @sql nvarchar(max);

	select @constraint_name = df.name from sys.default_constraints df
	join sys.columns c on c.object_id = df.parent_object_id and df.parent_column_id = c.column_id
	where parent_object_id = object_id('dbo.instance_details') and c.name = 'collector_sql_instance';

	set @sql = 'alter table dbo.instance_details drop constraint ['+@constraint_name+'];'
	exec (@sql);
	
	set @sql = 'alter table dbo.instance_details drop column collector_sql_instance;';
	exec (@sql);
end
go

select *
from dbo.instance_details
go
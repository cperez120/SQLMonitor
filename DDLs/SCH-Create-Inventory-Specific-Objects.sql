IF APP_NAME() = 'Microsoft SQL Server Management Studio - Query'
BEGIN
	SET QUOTED_IDENTIFIER OFF;
	SET ANSI_PADDING ON;
	SET CONCAT_NULL_YIELDS_NULL ON;
	SET ANSI_WARNINGS ON;
	SET NUMERIC_ROUNDABORT OFF;
	SET ARITHABORT ON;
END
GO

IF DB_NAME() = 'master'
	raiserror ('Kindly execute all queries in [DBA] database', 20, -1) with log;
go

ALTER DATABASE CURRENT SET MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT = ON;
go

ALTER DATABASE CURRENT ADD FILEGROUP MemoryOptimized CONTAINS MEMORY_OPTIMIZED_DATA;
go

ALTER DATABASE CURRENT ADD FILE (name='MemoryOptimized', filename='E:\Data\MemoryOptimized.ndf') TO FILEGROUP MemoryOptimized
go

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[all_server_stable_info]') AND type in (N'U'))
	DROP TABLE [dbo].[all_server_stable_info]
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[all_server_volatile_info]') AND type in (N'U'))
	DROP TABLE [dbo].[all_server_volatile_info]
GO

CREATE TABLE [dbo].[all_server_stable_info]
(
	[srv_name] [varchar](125) NOT NULL,
	[at_server_name] [varchar](125) NULL,
	[machine_name] [varchar](125) NULL,
	[server_name] [varchar](125) NULL,
	[ip] [varchar](30) NULL,
	[domain] [varchar](125) NULL,
	[host_name] [varchar](125) NULL,
	[product_version] [varchar](30) NULL,
	[edition] [varchar](50) NULL,
	[sqlserver_start_time_utc] [datetime2](7) NULL,
	[total_physical_memory_kb] [bigint] NULL,
	[os_start_time_utc] [datetime2](7) NULL,
	[cpu_count] [smallint] NULL,
	[scheduler_count] [smallint] NULL,
	[major_version_number] [smallint] NULL,
	[minor_version_number] [smallint] NULL,
	[collection_time] [datetime2] NULL default sysdatetime()
	CONSTRAINT pk_all_server_stable_info primary key nonclustered ([srv_name])
)
WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);
GO

CREATE TABLE [dbo].[all_server_volatile_info]
(
	[srv_name] [varchar](125) NOT NULL,
	[os_cpu] [decimal](20, 2) NULL,
	[sql_cpu] [decimal](20, 2) NULL,
	[pcnt_kernel_mode] [decimal](20, 2) NULL,
	[page_faults_kb] [decimal](20, 2) NULL,
	[blocked_counts] [int] NULL DEFAULT 0,
	[blocked_duration_max_seconds] [bigint] NULL DEFAULT 0,
	[available_physical_memory_kb] [bigint] NULL,
	[system_high_memory_signal_state] [varchar](20) NULL,
	[physical_memory_in_use_kb] [decimal](20, 2) NULL,
	[memory_grants_pending] [int] NULL,
	[connection_count] [int] NULL DEFAULT 0,
	[active_requests_count] [int] NULL DEFAULT 0,
	[waits_per_core_per_minute] [decimal](20, 2) NULL DEFAULT 0,
	[collection_time] [datetime2] NULL default sysdatetime()
	CONSTRAINT pk_all_server_volatile_info primary key nonclustered ([srv_name])
)
WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);
GO

if OBJECT_ID('dbo.vw_all_server_info') is null
	exec ('create view dbo.vw_all_server_info as select 1 as dummy;');
go

alter view dbo.vw_all_server_info
--with schemabinding
as
	select	si.srv_name, 
			/* stable info */
			at_server_name, machine_name, server_name, ip, domain, host_name, product_version, edition, sqlserver_start_time_utc, total_physical_memory_kb, os_start_time_utc, cpu_count, scheduler_count, major_version_number, minor_version_number,
			/* volatile info */
			os_cpu, sql_cpu, pcnt_kernel_mode, page_faults_kb, blocked_counts, blocked_duration_max_seconds, available_physical_memory_kb, system_high_memory_signal_state, physical_memory_in_use_kb, memory_grants_pending, connection_count, active_requests_count, waits_per_core_per_minute
	from dbo.all_server_stable_info as si
	left join dbo.all_server_volatile_info as vi
	on si.srv_name = vi.srv_name;
go


IF APP_NAME() = 'Microsoft SQL Server Management Studio - Query'
BEGIN
	SET NOCOUNT ON;

	-- Stable Info
	if	( (select count(1) from dbo.all_server_stable_info) <> (select count(distinct sql_instance) from dbo.instance_details) )
		or ( (select max(collection_time) from  dbo.all_server_stable_info) < dateadd(hour, -4, SYSDATETIME()) )
	begin
		delete dbo.all_server_stable_info;
		exec dbo.usp_GetAllServerInfo @result_to_table = 'dbo.all_server_stable_info',
					@output = 'srv_name, at_server_name, machine_name, server_name, ip, domain, host_name, product_version, edition, sqlserver_start_time_utc, total_physical_memory_kb, os_start_time_utc, cpu_count, scheduler_count, major_version_number, minor_version_number';
	end
	--select * from dbo.all_server_stable_info;

	-- Volatile Info
	DELETE dbo.all_server_volatile_info;
	exec dbo.usp_GetAllServerInfo @result_to_table = 'dbo.all_server_volatile_info',
				@output = 'srv_name, os_cpu, sql_cpu, pcnt_kernel_mode, page_faults_kb, blocked_counts, blocked_duration_max_seconds, available_physical_memory_kb, system_high_memory_signal_state, physical_memory_in_use_kb, memory_grants_pending, connection_count, active_requests_count, waits_per_core_per_minute';
	--select * from dbo.all_server_volatile_info;

	select * 
	from dbo.vw_all_server_info si
	--where si.srv_name = convert(varchar,SERVERPROPERTY('ServerName'))
END
GO

if not exists (select * from sys.columns c where c.object_id = OBJECT_ID('dbo.instance_details') and c.name = 'is_available')
    alter table dbo.instance_details add [is_available] bit NOT NULL default 1;
go
if not exists (select * from sys.columns c where c.object_id = OBJECT_ID('dbo.instance_details') and c.name = 'created_date_utc')
    alter table dbo.instance_details add [created_date_utc] datetime2 NOT NULL default SYSUTCDATETIME();
go
if not exists (select * from sys.columns c where c.object_id = OBJECT_ID('dbo.instance_details') and c.name = 'last_unavailability_time_utc')
    alter table dbo.instance_details add [last_unavailability_time_utc] datetime2 null;
go
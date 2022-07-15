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

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[all_server_info]') AND type in (N'U'))
	DROP TABLE [dbo].[all_server_info]
GO

CREATE TABLE [dbo].[all_server_info]
(
	[srv_name] [varchar](125) NOT NULL,
	[at_server_name] [varchar](125) NULL,
	[machine_name] [varchar](125) NOT NULL,
	[server_name] [varchar](125) NOT NULL,
	[ip] [varchar](30) NULL,
	[domain] [varchar](125) NULL,
	[host_name] [varchar](125) NOT NULL,
	[product_version] [varchar](30) NOT NULL,
	[edition] [varchar](50) NOT NULL,
	[sqlserver_start_time_utc] [datetime2](7) NOT NULL,
	[os_cpu] [decimal](20, 2) NOT NULL,
	[sql_cpu] [decimal](20, 2) NOT NULL,
	[pcnt_kernel_mode] [decimal](20, 2) NULL,
	[page_faults_kb] [decimal](20, 2) NULL,
	[blocked_counts] [int] NOT NULL DEFAULT 0,
	[blocked_duration_max_seconds] [bigint] NOT NULL DEFAULT 0,
	[total_physical_memory_kb] [bigint] NOT NULL,
	[available_physical_memory_kb] [bigint] NOT NULL,
	[system_high_memory_signal_state] [varchar](20) NOT NULL,
	[physical_memory_in_use_kb] [decimal](20, 2) NOT NULL,
	[memory_grants_pending] [int] NOT NULL,
	[connection_count] [int] NOT NULL DEFAULT 0,
	[active_requests_count] [int] NOT NULL DEFAULT 0,
	[waits_per_core_per_minute] [decimal](20, 2) NULL DEFAULT 0,
	[os_start_time_utc] [datetime2](7) NULL,
	[cpu_count] [smallint] NOT NULL,
	[scheduler_count] [smallint] NOT NULL,
	[major_version_number] [smallint] NOT NULL,
	[minor_version_number] [smallint] NOT NULL,
	CONSTRAINT pk_all_server_info primary key nonclustered ([srv_name])
)
WITH (MEMORY_OPTIMIZED = ON, DURABILITY = SCHEMA_AND_DATA);
GO

IF APP_NAME() = 'Microsoft SQL Server Management Studio - Query'
BEGIN
	SET NOCOUNT ON;

	DELETE dbo.all_server_info;
	exec dbo.usp_GetAllServerInfo @result_to_table = 'dbo.all_server_info';
	select * from dbo.all_server_info;

	select * 
	from dbo.all_server_info si
	where si.srv_name = convert(varchar,SERVERPROPERTY('ServerName'))
END
GO

if not exists (select * from sys.columns c where c.object_id = OBJECT_ID('dbo.instance_details') and c.name = 'is_available')
    alter table dbo.instance_details add [is_available] bit not null default 1;
go
if not exists (select * from sys.columns c where c.object_id = OBJECT_ID('dbo.instance_details') and c.name = 'created_date_utc')
    alter table dbo.instance_details add [created_date_utc] datetime2 not null default SYSUTCDATETIME();
go
if not exists (select * from sys.columns c where c.object_id = OBJECT_ID('dbo.instance_details') and c.name = 'last_unavailability_time_utc')
    alter table dbo.instance_details add [last_unavailability_time_utc] datetime2 null;
go
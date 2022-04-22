USE [DBA]
GO

/*
	1) Create Partition Function
	2) Create Partition Scheme
	3) Create table [dbo].[performance_counters] using Partition scheme
	4) Create dbo.perfmon_files table using Partition scheme
	5) Create table [dbo].[os_task_list] using Partition scheme
	5) Add/Remove Partition Boundaries
	
	Self Steps
	-----------
	1) Self StepsCreated a global default mail profile. https://github.com/imajaydwivedi/SQLDBA-SSMS-Solution/blob/0c2eaecca3dcf6745e3b2d262208c2f2257008bb/SQLDBATools-Inventory/DatabaseMail_Using_GMail.sql
	2) Create sp_WhoIsActive in [master] database. https://github.com/imajaydwivedi/SQLDBA-SSMS-Solution/blob/ae2541e37c28ea5b50887de993666bc81f29eba5/BlitzQueries/SCH-sp_WhoIsActive_v12_00(Modified).sql
	3) Install Brent Ozar's First Responder Kit. https://raw.githubusercontent.com/BrentOzarULTD/SQL-Server-First-Responder-Kit/dev/Install-All-Scripts.sql
			Install-DbaFirstResponderKit -SqlInstance workstation -Force -Verbose
	4) Install PowerShell modules
		Update-Module -Force -ErrorAction Continue -Verbose
		Update-Help -Force -ErrorAction Continue -Verbose
		Install-Module dbatools, enhancedhtml2, sqlserver, poshrsjob -Scope AllUsers -Force -ErrorAction Continue -Verbose

*/

-- Partition function & scheme for [datetime2]
create partition function pf_dba (datetime2)
as range right for values ('2022-03-25 00:00:00.0000000')
go

create partition scheme ps_dba as partition pf_dba all to ([primary])
go

-- Partition function & scheme for [datetime]
create partition function pf_dba_datetime (datetime)
as range right for values ('2022-03-25 00:00:00.000')
go

create partition scheme ps_dba_datetime as partition pf_dba_datetime all to ([primary])
go

/* ***** 3) Create table [dbo].[performance_counters] using Partition scheme ***************** */
-- drop table [dbo].[performance_counters]
create table [dbo].[performance_counters]
(
	[collection_time_utc] [datetime2](7) NOT NULL,
	[host_name] [varchar](255) NOT NULL,
	[path] [nvarchar](2000) NOT NULL,
	[object] [varchar](255) NOT NULL,
	[counter] [varchar](255) NOT NULL,
	[value] numeric(38,10) NULL,
	[instance] [nvarchar](255) NULL
) on ps_dba ([collection_time_utc])
go

create clustered index ci_performance_counters on [dbo].[performance_counters] 
	([collection_time_utc], [host_name], object, counter, [instance], [value]) on ps_dba ([collection_time_utc])
go
create nonclustered index nci_counter_collection_time_utc
	on [dbo].[performance_counters] ([counter],[collection_time_utc]) on ps_dba ([collection_time_utc])
GO

/* ***** 4) Create dbo.perfmon_files table using Partition scheme ***************** */
-- drop table [dbo].[perfmon_files]
CREATE TABLE [dbo].[perfmon_files]
(
	[host_name] [varchar](255) NOT NULL,
	[file_name] [varchar](255) NOT NULL,
	[file_path] [varchar](255) NOT NULL,
	[collection_time_utc] [datetime2](7) NOT NULL default sysutcdatetime(),
	CONSTRAINT [pk_perfmon_files] PRIMARY KEY CLUSTERED 
	(
		[file_name] ASC,
		[collection_time_utc] ASC
	) on ps_dba ([collection_time_utc])
) on ps_dba ([collection_time_utc])
GO

/* ***** 5) Create table [dbo].[os_task_list] using Partition scheme ***************** */
-- drop table [dbo].[os_task_list]
CREATE TABLE [dbo].[os_task_list]
(	
	[collection_time_utc] [datetime2](7) NOT NULL,
	[host_name] [varchar](255) NOT NULL,
	[task_name] [nvarchar](100) not null,
	[pid] bigint not null,
	[session_name] [varchar](20) null,
	[memory_kb] bigint NULL,
	[status] [varchar](30) NULL,
	[user_name] [varchar](200) NOT NULL,
	[cpu_time] [char](10) NOT NULL,
	[cpu_time_seconds] bigint NOT NULL,
	[window_title] [nvarchar](2000) NULL
) on ps_dba ([collection_time_utc])
go

create clustered index ci_os_task_list on [dbo].[os_task_list] ([collection_time_utc], [host_name], [task_name]) on ps_dba ([collection_time_utc])
go
create nonclustered index nci_user_name on [dbo].[os_task_list] ([collection_time_utc], [host_name], [user_name]) on ps_dba ([collection_time_utc])
go
create nonclustered index nci_window_title on [dbo].[os_task_list] ([collection_time_utc], [host_name], [window_title]) on ps_dba ([collection_time_utc])
go
create nonclustered index nci_cpu_time_seconds on [dbo].[os_task_list] ([collection_time_utc], [host_name], [cpu_time_seconds]) on ps_dba ([collection_time_utc])
go
create nonclustered index nci_memory_kb on [dbo].[os_task_list] ([collection_time_utc], [host_name], [memory_kb]) on ps_dba ([collection_time_utc])
go

-- drop table [dbo].[wait_stats]
CREATE TABLE [dbo].[wait_stats]
(
	[collection_time_utc] datetime2 not null,
	[wait_type] [nvarchar](60) NOT NULL,
	[waiting_tasks_count] [bigint] NOT NULL,
	[wait_time_ms] [bigint] NOT NULL,
	[max_wait_time_ms] [bigint] NOT NULL,
	[signal_wait_time_ms] [bigint] NOT NULL
) on ps_dba ([collection_time_utc])
GO

--create clustered index ci_wait_stats on [dbo].[wait_stats] ([collection_time_utc], [wait_type]) on ps_dba ([collection_time_utc])
--go

alter table [dbo].[wait_stats] add primary key ([collection_time_utc], [wait_type]) on ps_dba ([collection_time_utc])
go

-- DROP VIEW [dbo].[vw_wait_stats_deltas];
CREATE VIEW [dbo].[vw_wait_stats_deltas] 
WITH SCHEMABINDING 
AS
WITH RowDates as ( 
	SELECT ROW_NUMBER() OVER (ORDER BY [collection_time_utc]) ID, [collection_time_utc]
	FROM [dbo].[wait_stats] 
	--WHERE [collection_time_utc] between @start_time and @end_time
	GROUP BY [collection_time_utc]
)
, collection_time_utcs as
(	SELECT ThisDate.collection_time_utc, LastDate.collection_time_utc as Previouscollection_time_utc
    FROM RowDates ThisDate
    JOIN RowDates LastDate
    ON ThisDate.ID = LastDate.ID + 1
)
--select * from collection_time_utcs
SELECT w.collection_time_utc, w.wait_type, COALESCE(wc.WaitCategory, 'Other') AS WaitCategory, COALESCE(wc.Ignorable,0) AS Ignorable
, DATEDIFF(ss, wPrior.collection_time_utc, w.collection_time_utc) AS ElapsedSeconds
, (w.wait_time_ms - wPrior.wait_time_ms) AS wait_time_ms_delta
, (w.wait_time_ms - wPrior.wait_time_ms) / 60000.0 AS wait_time_minutes_delta
, (w.wait_time_ms - wPrior.wait_time_ms) / 1000.0 / DATEDIFF(ss, wPrior.collection_time_utc, w.collection_time_utc) AS wait_time_minutes_per_minute
, (w.signal_wait_time_ms - wPrior.signal_wait_time_ms) AS signal_wait_time_ms_delta
, (w.waiting_tasks_count - wPrior.waiting_tasks_count) AS waiting_tasks_count_delta
FROM [dbo].[wait_stats] w
--INNER HASH JOIN collection_time_utcs Dates
INNER JOIN collection_time_utcs Dates
ON Dates.collection_time_utc = w.collection_time_utc
INNER JOIN [dbo].[wait_stats] wPrior ON w.wait_type = wPrior.wait_type AND Dates.Previouscollection_time_utc = wPrior.collection_time_utc
LEFT OUTER JOIN [dbo].[BlitzFirst_WaitStats_Categories] wc ON w.wait_type = wc.WaitType
WHERE [w].[wait_time_ms] >= [wPrior].[wait_time_ms]
--ORDER BY w.collection_time_utc, wait_time_ms_delta desc
GO

CREATE SCHEMA [bkp]
GO
CREATE SCHEMA [poc]
GO
CREATE SCHEMA [stg]
GO
CREATE SCHEMA [tst]
GO


/* Validate Partition Data */
SELECT SCHEMA_NAME(o.schema_id)+'.'+ o.name as TableName,
	pf.name as PartitionFunction,
	ds.name AS PartitionScheme, 
	p.partition_number AS PartitionNumber, 
	CASE pf.boundary_value_on_right WHEN 1 THEN 'RIGHT' ELSE 'LEFT' END AS PartitionFunctionRange, 
	prv_left.value AS LowerBoundaryValue, 
	prv_right.value AS UpperBoundaryValue, 
	fg.name AS FileGroupName,
	p.[row_count] as TotalRows,
	CONVERT(DECIMAL(12,2), p.reserved_page_count*8/1024.0) as ReservedSpaceMB,
	CONVERT(DECIMAL(12,2), p.used_page_count*8/1024.0) as UsedSpaceMB
FROM sys.dm_db_partition_stats AS p (NOLOCK)
	INNER JOIN sys.indexes AS i (NOLOCK) ON i.[object_id] = p.[object_id] AND i.index_id = p.index_id
	INNER JOIN sys.data_spaces AS ds (NOLOCK) ON ds.data_space_id = i.data_space_id
	INNER JOIN sys.objects AS o (NOLOCK) ON o.object_id = p.object_id
	INNER JOIN sys.partition_schemes AS ps (NOLOCK) ON ps.data_space_id = ds.data_space_id
	INNER JOIN sys.partition_functions AS pf (NOLOCK) ON pf.function_id = ps.function_id
	INNER JOIN sys.destination_data_spaces AS dds2 (NOLOCK) ON dds2.partition_scheme_id = ps.data_space_id AND dds2.destination_id = p.partition_number
	INNER JOIN sys.filegroups AS fg (NOLOCK) ON fg.data_space_id = dds2.data_space_id
	LEFT OUTER JOIN sys.partition_range_values AS prv_left (NOLOCK) ON ps.function_id = prv_left.function_id AND prv_left.boundary_id = p.partition_number - 1
	LEFT OUTER JOIN sys.partition_range_values AS prv_right (NOLOCK) ON ps.function_id = prv_right.function_id AND prv_right.boundary_id = p.partition_number
WHERE
	OBJECTPROPERTY(p.[object_id], 'IsMSShipped') = 0
ORDER BY p.partition_number;	
go

/* Add boundaries to partition. 1 boundary per hour */
set nocount on;
declare @partition_boundary datetime2;
declare @target_boundary_value datetime2; /* 3 months back date */
set @target_boundary_value = DATEADD(mm,DATEDIFF(mm,0,GETDATE())-3,0);
set @target_boundary_value = '2022-03-25 19:00:00.000'

declare cur_boundaries cursor local fast_forward for
		select convert(datetime2,prv.value) as boundary_value
		from sys.partition_range_values prv
		join sys.partition_functions pf on pf.function_id = prv.function_id
		where pf.name = 'pf_dba' and convert(datetime2,prv.value) < @target_boundary_value
		order by prv.value asc;

open cur_boundaries;
fetch next from cur_boundaries into @partition_boundary;
while @@FETCH_STATUS = 0
begin
	--print @partition_boundary
	alter partition function pf_dba() merge range (@partition_boundary);

	fetch next from cur_boundaries into @partition_boundary;
end
CLOSE cur_boundaries
DEALLOCATE cur_boundaries;
go


/* Remove boundaries with retention of 3 months */
set nocount on;
declare @current_boundary_value datetime2;
declare @target_boundary_value datetime2; /* last day of new quarter */
set @target_boundary_value = DATEADD (dd, -1, DATEADD(qq, DATEDIFF(qq, 0, GETDATE()) +2, 0));

select top 1 @current_boundary_value = convert(datetime2,prv.value)
from sys.partition_range_values prv
join sys.partition_functions pf on pf.function_id = prv.function_id
where pf.name = 'pf_dba'
order by prv.value desc;

select [@current_boundary_value] = @current_boundary_value, [@target_boundary_value] = @target_boundary_value;

while (@current_boundary_value < @target_boundary_value)
begin
	set @current_boundary_value = DATEADD(hour,1,@current_boundary_value);
	--print @current_boundary_value
	alter partition scheme ps_dba next used [primary];
	alter partition function pf_dba() split range (@current_boundary_value);	
end
go

select * from [dbo].[os_task_list]
go
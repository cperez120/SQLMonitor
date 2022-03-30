USE [DBA]
GO

/*
	1) Create Partition Function
	2) Create Partition Scheme
	3) Create table [dbo].[performance_counters] using Partition scheme
	4) Add/Remove Partition Boundaries
	5) Create dbo.perfmon_files table
	6) Create table [dbo].[os_task_list] using Partition scheme

*/
create partition function pf_dba (datetime2)
as range right for values ('2022-03-25 00:00:00.0000000')
go

create partition scheme ps_dba as partition pf_dba all to ([primary])
go

-- drop table [dbo].[performance_counters]
create table [dbo].[performance_counters]
(
	[collection_time_utc] [datetime2](7) NOT NULL,
	[computer_name] [varchar](200) NOT NULL,
	[path] [nvarchar](2000) NOT NULL,
	[object] [varchar](255) NOT NULL,
	[counter] [varchar](255) NOT NULL,
	[value] numeric(38,10) NULL,
	[instance] [nvarchar](255) NULL
) on ps_dba ([collection_time_utc])
go

create clustered index ci_performance_counters on [dbo].[performance_counters] ([collection_time_utc], object, counter, [instance], [value])
go


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


CREATE TABLE [dbo].[perfmon_files](
	[server_name] [varchar](100) NOT NULL,
	[file_name] [varchar](255) NOT NULL,
	[file_path] [varchar](255) NOT NULL,
	[collection_time_utc] [datetime2](7) NOT NULL,
 CONSTRAINT [pk_perfmon_files] PRIMARY KEY CLUSTERED 
(
	[file_name] ASC,
	[collection_time_utc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[perfmon_files] ADD  DEFAULT (sysutcdatetime()) FOR [collection_time_utc]
GO



-- drop table [dbo].[os_task_list]
CREATE TABLE [dbo].[os_task_list]
(	
	[collection_time_utc] [datetime2](7) NOT NULL,
	[task_name] [nvarchar](100) not null,
	[pid] bigint not null,
	[session_name] [varchar](20) not null,
	[memory_kb] bigint NOT NULL,
	[status] [varchar](30) NULL,
	[user_name] [varchar](200) NOT NULL,
	[cpu_time] [char](10) NOT NULL,
	[cpu_time_seconds] bigint NOT NULL,
	[window_title] [nvarchar](2000) NULL
) on ps_dba ([collection_time_utc])
go

create clustered index ci_os_task_list on [dbo].[os_task_list] ([collection_time_utc], [task_name])
go
create nonclustered index nci_user_name on [dbo].[os_task_list] ([collection_time_utc], [user_name])
go
create nonclustered index nci_window_title on [dbo].[os_task_list] ([collection_time_utc], [window_title])
go
create nonclustered index nci_cpu_time_seconds on [dbo].[os_task_list] ([collection_time_utc], [cpu_time_seconds])
go
create nonclustered index nci_memory_kb on [dbo].[os_task_list] ([collection_time_utc], [memory_kb])
go

select * from [dbo].[os_task_list]
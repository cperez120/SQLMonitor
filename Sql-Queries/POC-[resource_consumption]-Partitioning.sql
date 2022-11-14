use DBA
go

if object_id('dbo.vw_resource_consumption') is not null
	exec ('drop view vw_resource_consumption')
go
if object_id('dbo.resource_consumption') is not null
	drop table dbo.resource_consumption
go

DROP TABLE IF EXISTS [dbo].[resource_consumption];
GO
CREATE TABLE [dbo].[resource_consumption]
(
	[row_id] [bigint] NOT NULL,
	[start_time] [datetime2](7) NOT NULL,
	[event_time] [datetime2](7) NOT NULL,
	[event_name] [nvarchar](60) NOT NULL,
	[session_id] [int] NOT NULL,
	[request_id] [int] NOT NULL,
	[result] [varchar](50) NULL,
	[database_name] [varchar](255) NULL,
	[client_app_name] [varchar](255) NULL,
	[username] [varchar](255) NULL,
	[cpu_time] [bigint] NULL,
	[duration_seconds] [bigint] NULL,
	[logical_reads] [bigint] NULL,
	[physical_reads] [bigint] NULL,
	[row_count] [bigint] NULL,
	[writes] [bigint] NULL,
	[spills] [bigint] NULL,
	--[sql_text] [varchar](max) NULL,
	[client_hostname] [varchar](255) NULL,
	[session_resource_pool_id] [int] NULL,
	[session_resource_group_id] [int] NULL,
	[scheduler_id] [int] NULL
	,index cci_resource_consumption clustered columnstore on ps_dba_datetime2_daily ([event_time])
) on ps_dba_datetime2_daily ([event_time])
go

-- DROP VIEW [dbo].[vw_resource_consumption];
if OBJECT_ID('[dbo].[vw_resource_consumption]') is null
	exec ('CREATE VIEW [dbo].[vw_resource_consumption] AS SELECT 1 as Dummy');
go
ALTER VIEW [dbo].[vw_resource_consumption]
WITH SCHEMABINDING 
AS
SELECT rc.[row_id], rc.[start_time], rc.[event_time], rc.[event_name], rc.[session_id], rc.[request_id], rc.[result], rc.[database_name], rc.[client_app_name], rc.[username], rc.[cpu_time], rc.[duration_seconds], rc.[logical_reads], rc.[physical_reads], rc.[row_count], rc.[writes], rc.[spills], txt.[sql_text], /* rc.[query_hash], rc.[query_plan_hash], */ rc.[client_hostname], rc.[session_resource_pool_id], rc.[session_resource_group_id], rc.[scheduler_id]
FROM [dbo].[resource_consumption] rc
LEFT JOIN [dbo].[resource_consumption_queries] txt
	ON rc.event_time = txt.event_time
	AND rc.start_time = txt.start_time
	AND rc.row_id = txt.row_id
GO

if exists (select * from sys.objects where [name] = N'tgr_insert_resource_consumption' and [type] = 'TR')
	drop trigger [dbo].tgr_insert_resource_consumption
GO
create trigger dbo.tgr_insert_resource_consumption on dbo.vw_resource_consumption
instead of insert as
begin
	set nocount on;

	insert dbo.resource_consumption
	(	[row_id], [start_time], [event_time], [event_name], [session_id], [request_id], [result], [database_name], 
		[client_app_name], [username], [cpu_time], [duration_seconds], [logical_reads], [physical_reads], [row_count], 
		[writes], [spills], [client_hostname], [session_resource_pool_id], [session_resource_group_id], [scheduler_id] )
	select [row_id], [start_time], [event_time], [event_name], [session_id], [request_id], [result], [database_name], 
		[client_app_name], [username], [cpu_time], [duration_seconds], [logical_reads], [physical_reads], [row_count], 
		[writes], [spills], [client_hostname], [session_resource_pool_id], [session_resource_group_id], [scheduler_id]
	from inserted;

	insert dbo.resource_consumption_queries
	(	[row_id], [start_time], [event_time], [sql_text] )
	select [row_id], [start_time], [event_time], [sql_text]
	from inserted;
end
go



exec sp_BlitzIndex @DatabaseName = 'DBA', @TableName = 'resource_consumption_partitioned'
go
exec sp_BlitzIndex @DatabaseName = 'DBA', @TableName = 'resource_consumption'
go

select DATEDIFF(day,min(event_time), max(event_time)), count(*)
from dbo.resource_consumption_partitioned
go

--exec sp_rename 'dbo.resource_consumption', 'resource_consumption_rowstore'
--exec sp_rename 'dbo.resource_consumption_partitioned', 'resource_consumption'

/*
********************************************************************************
	Columnstore Table -> [resource_consumption_partitioned]
------------------------------------------------
14 days of dbo.resource_consumption.
625k rows
21 seconds from base table to CCI table for above 1.2 millions rows
Got 2 partitions. Total 2 Row groups.
one row group of 162k rows. other 463k rows.

total size ==> [73 PARTITIONS] 625,910 rows; 24.6MB; 23.5MB Columnstore; 1.2MB Dictionaries

[PARTITIONED BY: event_time][CX]  [21 INCLUDES]  client_app_name {varchar (255)}, client_hostname {varchar (255)}, cpu_time {bigint 8}, database_name {varchar (255)}, duration_seconds {bigint 8}, event_name {nvarchar (60)}, event_time {datetime2 8}, logical_reads {bigint 8}, physical_reads {bigint 8}, request_id {int 4}, result {varchar (50)}, row_count {bigint 8}, row_id {bigint 8}, scheduler_id {int 4}, session_id {int 4}, session_resource_group_id {int 4}, session_resource_pool_id {int 4}, spills {bigint 8}, start_time {datetime2 8}, username {varchar (255)}, writes {bigint 8}

CREATE CLUSTERED COLUMNSTORE INDEX [CCI] on [DBA].[dbo].[resource_consumption_partitioned];


********************************************************************************
	Rowstore Table -> [resource_consumption] 
---------------------------------------------

[PARTITIONED BY: event_time][CX] [PK] [3 KEYS] event_time {datetime2 8}, start_time {datetime2 8}, row_id {bigint 8}
[5521 PARTITIONS] 626,217 rows; 1.4GB; 315.5MB LOB
Partitions 1 - 5521 use PAGE

*/

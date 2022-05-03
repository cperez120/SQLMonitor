USE DBA
GO

select 'sys.partition_functions' as [RunningQuery], * from sys.partition_functions pf with(nolock) where pf.name = 'pf_dba'
select 'sys.partition_schemes' as [RunningQuery], * from sys.partition_schemes ps with(nolock) where ps.name = 'ps_dba'
select 'sys.partition_range_values' as [RunningQuery], count(*) as range_counts from sys.partition_range_values with(nolock)
where function_id = (select pf.function_id from sys.partition_functions pf with(nolock) where pf.name = 'pf_dba')
go

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
		AND p.index_id in (0,1) and i.index_id in (0,1)
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
	AND  o.name in ('performance_counters','os_task_list','WhoIsActive','wait_stats')
	AND p.[row_count] > 0
ORDER BY LowerBoundaryValue, UpperBoundaryValue, o.name
go
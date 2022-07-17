use DBA
go

exec sp_spaceused 'performance_counters'
go
/*
name	rows	reserved	data	index_size	unused
performance_counters	50820017            	22691896 KB	13138640 KB	6541168 KB	3012088 KB
22 gb

ci_performance_counters
nci_counter_collection_time_utc
*/
select 22691896/1024 as size_mb


EXEC sp_estimate_data_compression_savings 'dbo', 'performance_counters', NULL, NULL, 'PAGE' ;  

if not exists (select 1 from sys.partitions p inner join sys.tables t on p.object_id = t.object_id where p.data_compression > 0 and t.name = 'performance_counters')
	ALTER TABLE dbo.performance_counters REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);   
GO

alter table dbo.performance_counters drop column [path];




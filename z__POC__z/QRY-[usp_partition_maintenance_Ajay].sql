use DBA
go

--EXEC dbo.usp_partition_maintenance_Ajay @verbose = 2
--EXEC dbo.usp_partition_maintenance_Ajay @step = 'add_partition_datetime2_hourly_old', @verbose = 2, @dry_run = 1
--EXEC dbo.usp_partition_maintenance_Ajay @step = 'add_partition_datetime2_hourly', @verbose = 2, @dry_run = 1
--EXEC dbo.usp_partition_maintenance_Ajay @step = 'add_partition_datetime2_daily', @verbose = 2, @dry_run = 1
--EXEC dbo.usp_partition_maintenance_Ajay @step = 'add_partition_datetime2_monthly', @verbose = 2, @dry_run = 1
--EXEC dbo.usp_partition_maintenance_Ajay @step = 'add_partition_datetime2_quarterly', @verbose = 2, @dry_run = 1
----
--EXEC dbo.usp_partition_maintenance_Ajay @step = 'add_partition_datetime_hourly_old', @verbose = 2, @dry_run = 1
--EXEC dbo.usp_partition_maintenance_Ajay @step = 'add_partition_datetime_hourly', @verbose = 2, @dry_run = 1
--EXEC dbo.usp_partition_maintenance_Ajay @step = 'add_partition_datetime_daily', @verbose = 2, @dry_run = 1
--EXEC dbo.usp_partition_maintenance_Ajay @step = 'add_partition_datetime_monthly', @verbose = 2, @dry_run = 1
--EXEC dbo.usp_partition_maintenance_Ajay @step = 'add_partition_datetime_quarterly', @verbose = 2, @dry_run = 1
----
--EXEC dbo.usp_partition_maintenance_Ajay @step = 'remove_partition_datetime2_hourly_old', @hourly_retention_days = 30, @verbose = 2, @dry_run = 1;
--EXEC dbo.usp_partition_maintenance_Ajay @step = 'remove_partition_datetime2_hourly', @hourly_retention_days = 30, @verbose = 2, @dry_run = 1;
--EXEC dbo.usp_partition_maintenance_Ajay @step = 'remove_partition_datetime2_daily', @daily_retention_days = 30, @verbose = 2, @dry_run = 1;
--EXEC dbo.usp_partition_maintenance_Ajay @step = 'remove_partition_datetime2_monthly', @monthly_retention_days = 30, @verbose = 2, @dry_run = 1;
--EXEC dbo.usp_partition_maintenance_Ajay @step = 'remove_partition_datetime2_quarterly', @quarterly_retention_days = 30, @verbose = 2, @dry_run = 1;
--
--EXEC dbo.usp_partition_maintenance_Ajay @step = 'remove_partition_datetime_hourly_old', @hourly_retention_days = 30, @verbose = 2, @dry_run = 1;
--EXEC dbo.usp_partition_maintenance_Ajay @step = 'remove_partition_datetime_hourly', @hourly_retention_days = 30, @verbose = 2, @dry_run = 1;
--EXEC dbo.usp_partition_maintenance_Ajay @step = 'remove_partition_datetime_daily', @daily_retention_days = 30, @verbose = 2, @dry_run = 1;
--EXEC dbo.usp_partition_maintenance_Ajay @step = 'remove_partition_datetime_monthly', @monthly_retention_days = 30, @verbose = 2, @dry_run = 1;
--EXEC dbo.usp_partition_maintenance_Ajay @step = 'remove_partition_datetime_quarterly', @quarterly_retention_days = 30, @verbose = 2, @dry_run = 1;
----
/*
'add_partition_datetime2_hourly','add_partition_datetime2_daily',
'add_partition_datetime2_monthly','add_partition_datetime2_quarterly',
'add_partition_datetime_hourly','add_partition_datetime_daily',
'add_partition_datetime_monthly','add_partition_datetime_quarterly'
*/
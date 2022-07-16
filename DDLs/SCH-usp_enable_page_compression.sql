IF DB_NAME() = 'master'
	raiserror ('Kindly execute all queries in [DBA] database', 20, -1) with log;
go

SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ANSI_WARNINGS ON;
SET NUMERIC_ROUNDABORT OFF;
SET ARITHABORT ON;
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'usp_active_requests_count')
    EXEC ('CREATE PROC dbo.usp_active_requests_count AS SELECT ''stub version, to be replaced''')
GO

ALTER PROCEDURE dbo.usp_enable_page_compression
	@count smallint = -1 output
WITH RECOMPILE, EXECUTE AS OWNER AS 
BEGIN

	/*
		Version:		1.0.0
		Date:			2022-07-15

		exec usp_enable_page_compression;
	*/
	SET NOCOUNT ON; 
	
	-- dbo.performance_counters
	if not exists (select 1 from sys.partitions p inner join sys.tables t on p.object_id = t.object_id where p.data_compression > 0 and t.name = 'performance_counters')
		ALTER TABLE dbo.performance_counters REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE);


END
GO

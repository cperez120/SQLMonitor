IF DB_NAME() = 'master'
	raiserror ('Kindly execute all queries in [DBA] database', 20, -1) with log;
go

-- Drop Existing PK
IF OBJECT_ID('dbo.WhoIsActive') IS NOT NULL
BEGIN
	IF NOT EXISTS (select * from sys.indexes where [object_id] = OBJECT_ID('dbo.WhoIsActive') and data_space_id > 1)
		ALTER TABLE dbo.WhoIsActive DROP CONSTRAINT pk_WhoIsActive
	ELSE
		SELECT '[dbo].[WhoIsActive] table already partitioned.';
END
ELSE
	SELECT '[dbo].[WhoIsActive] table not found';
GO

-- Create PK with Partitioning
IF OBJECT_ID('dbo.WhoIsActive') IS NOT NULL AND NOT EXISTS (select * from sys.indexes where [object_id] = OBJECT_ID('dbo.WhoIsActive') and data_space_id > 1)
	ALTER TABLE dbo.WhoIsActive ADD CONSTRAINT pk_WhoIsActive PRIMARY KEY CLUSTERED  (collection_time, cpu_rank)
		ON [ps_dba_datetime] (collection_time);
GO
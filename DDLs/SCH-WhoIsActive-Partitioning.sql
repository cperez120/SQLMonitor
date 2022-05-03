USE DBA
GO

-- Drop Existing PK
ALTER TABLE dbo.WhoIsActive DROP CONSTRAINT pk_WhoIsActive
GO

-- Create PK with Partitioning
ALTER TABLE dbo.WhoIsActive ADD CONSTRAINT pk_WhoIsActive PRIMARY KEY CLUSTERED  (collection_time, cpu_rank)
ON [ps_dba_datetime] (collection_time)
GO
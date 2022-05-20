CREATE TABLE [dbo].[performance_counters] (
    [collection_time_utc] DATETIME2 (7)    NOT NULL,
    [host_name]           VARCHAR (255)    NOT NULL,
    [path]                NVARCHAR (2000)  NOT NULL,
    [object]              VARCHAR (255)    NOT NULL,
    [counter]             VARCHAR (255)    NOT NULL,
    [value]               NUMERIC (38, 10) NULL,
    [instance]            NVARCHAR (255)   NULL,
    [sql_instance_id]     INT              NULL
) ON [ps_dba] ([collection_time_utc]);


GO
CREATE CLUSTERED INDEX [ci_performance_counters]
    ON [dbo].[performance_counters]([collection_time_utc] ASC, [host_name] ASC, [object] ASC, [counter] ASC, [instance] ASC, [value] ASC)
    ON [ps_dba] ([collection_time_utc]);


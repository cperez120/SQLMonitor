CREATE TABLE [dbo].[wait_stats] (
    [collection_time_utc] DATETIME2 (7) NOT NULL,
    [wait_type]           NVARCHAR (60) NOT NULL,
    [waiting_tasks_count] BIGINT        NOT NULL,
    [wait_time_ms]        BIGINT        NOT NULL,
    [max_wait_time_ms]    BIGINT        NOT NULL,
    [signal_wait_time_ms] BIGINT        NOT NULL,
    PRIMARY KEY CLUSTERED ([collection_time_utc] ASC, [wait_type] ASC) ON [ps_dba] ([collection_time_utc])
) ON [ps_dba] ([collection_time_utc]);


CREATE TABLE [dbo].[resource_consumption] (
    [row_id]                    BIGINT          IDENTITY (1, 1) NOT NULL,
    [start_time]                DATETIME2 (7)   NOT NULL,
    [event_time]                DATETIME2 (7)   NOT NULL,
    [event_name]                NVARCHAR (60)   NOT NULL,
    [session_id]                INT             NOT NULL,
    [request_id]                INT             NOT NULL,
    [result]                    VARCHAR (50)    NULL,
    [database_name]             VARCHAR (255)   NULL,
    [client_app_name]           VARCHAR (255)   NULL,
    [username]                  VARCHAR (255)   NULL,
    [cpu_time]                  BIGINT          NULL,
    [duration_seconds]          BIGINT          NULL,
    [logical_reads]             BIGINT          NULL,
    [physical_reads]            BIGINT          NULL,
    [row_count]                 BIGINT          NULL,
    [writes]                    BIGINT          NULL,
    [spills]                    BIGINT          NULL,
    [sql_text]                  VARCHAR (MAX)   NULL,
    [query_hash]                VARBINARY (255) NULL,
    [query_plan_hash]           VARBINARY (255) NULL,
    [client_hostname]           VARCHAR (255)   NULL,
    [session_resource_pool_id]  INT             NULL,
    [session_resource_group_id] INT             NULL,
    [scheduler_id]              INT             NULL,
    CONSTRAINT [pk_resource_consumption] PRIMARY KEY CLUSTERED ([event_time] ASC, [start_time] ASC, [row_id] ASC) ON [ps_dba] ([event_time])
) ON [ps_dba] ([event_time]);


GO
CREATE UNIQUE NONCLUSTERED INDEX [uq_resource_consumption]
    ON [dbo].[resource_consumption]([start_time] ASC, [event_time] ASC, [row_id] ASC)
    ON [ps_dba] ([event_time]);


GO
GRANT SELECT
    ON OBJECT::[dbo].[resource_consumption] TO [grafana]
    AS [dbo];


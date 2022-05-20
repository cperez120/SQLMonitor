CREATE TABLE [dbo].[os_task_list] (
    [collection_time_utc] DATETIME2 (7)   NOT NULL,
    [host_name]           VARCHAR (255)   NOT NULL,
    [task_name]           NVARCHAR (100)  NOT NULL,
    [pid]                 BIGINT          NOT NULL,
    [session_name]        VARCHAR (20)    NULL,
    [memory_kb]           BIGINT          NULL,
    [status]              VARCHAR (30)    NULL,
    [user_name]           VARCHAR (200)   NOT NULL,
    [cpu_time]            CHAR (10)       NOT NULL,
    [cpu_time_seconds]    BIGINT          NOT NULL,
    [window_title]        NVARCHAR (2000) NULL
) ON [ps_dba] ([collection_time_utc]);


GO
CREATE CLUSTERED INDEX [ci_os_task_list]
    ON [dbo].[os_task_list]([collection_time_utc] ASC, [host_name] ASC, [task_name] ASC)
    ON [ps_dba] ([collection_time_utc]);


GO
CREATE NONCLUSTERED INDEX [nci_user_name]
    ON [dbo].[os_task_list]([collection_time_utc] ASC, [host_name] ASC, [user_name] ASC)
    ON [ps_dba] ([collection_time_utc]);


GO
CREATE NONCLUSTERED INDEX [nci_window_title]
    ON [dbo].[os_task_list]([collection_time_utc] ASC, [host_name] ASC, [window_title] ASC)
    ON [ps_dba] ([collection_time_utc]);


GO
CREATE NONCLUSTERED INDEX [nci_cpu_time_seconds]
    ON [dbo].[os_task_list]([collection_time_utc] ASC, [host_name] ASC, [cpu_time_seconds] ASC)
    ON [ps_dba] ([collection_time_utc]);


GO
CREATE NONCLUSTERED INDEX [nci_memory_kb]
    ON [dbo].[os_task_list]([collection_time_utc] ASC, [host_name] ASC, [memory_kb] ASC)
    ON [ps_dba] ([collection_time_utc]);


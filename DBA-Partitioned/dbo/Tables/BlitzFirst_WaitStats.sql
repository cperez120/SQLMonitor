CREATE TABLE [dbo].[BlitzFirst_WaitStats] (
    [ID]                  INT                IDENTITY (1, 1) NOT NULL,
    [ServerName]          NVARCHAR (128)     NULL,
    [CheckDate]           DATETIMEOFFSET (7) NULL,
    [wait_type]           NVARCHAR (60)      NULL,
    [wait_time_ms]        BIGINT             NULL,
    [signal_wait_time_ms] BIGINT             NULL,
    [waiting_tasks_count] BIGINT             NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_ServerName_wait_type_CheckDate_Includes]
    ON [dbo].[BlitzFirst_WaitStats]([ServerName] ASC, [wait_type] ASC, [CheckDate] ASC)
    INCLUDE([wait_time_ms], [signal_wait_time_ms], [waiting_tasks_count]);


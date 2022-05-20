CREATE TABLE [dbo].[BlitzFirst_PerfmonStats] (
    [ID]               INT                IDENTITY (1, 1) NOT NULL,
    [ServerName]       NVARCHAR (128)     NULL,
    [CheckDate]        DATETIMEOFFSET (7) NULL,
    [object_name]      NVARCHAR (128)     NOT NULL,
    [counter_name]     NVARCHAR (128)     NOT NULL,
    [instance_name]    NVARCHAR (128)     NULL,
    [cntr_value]       BIGINT             NULL,
    [cntr_type]        INT                NOT NULL,
    [value_delta]      BIGINT             NULL,
    [value_per_second] DECIMAL (18, 2)    NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


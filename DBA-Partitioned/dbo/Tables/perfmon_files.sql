CREATE TABLE [dbo].[perfmon_files] (
    [host_name]           VARCHAR (255) NOT NULL,
    [file_name]           VARCHAR (255) NOT NULL,
    [file_path]           VARCHAR (255) NOT NULL,
    [collection_time_utc] DATETIME2 (7) DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [pk_perfmon_files] PRIMARY KEY CLUSTERED ([file_name] ASC, [collection_time_utc] ASC) ON [ps_dba] ([collection_time_utc])
) ON [ps_dba] ([collection_time_utc]);


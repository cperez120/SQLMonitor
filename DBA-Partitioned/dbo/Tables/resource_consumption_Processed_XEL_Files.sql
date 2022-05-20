CREATE TABLE [dbo].[resource_consumption_Processed_XEL_Files] (
    [file_path]            VARCHAR (2000) NOT NULL,
    [collection_time_utc]  DATETIME2 (7)  DEFAULT (sysutcdatetime()) NOT NULL,
    [is_processed]         BIT            DEFAULT ((0)) NOT NULL,
    [is_removed_from_disk] BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [pk_resource_consumption_Processed_XEL_Files] PRIMARY KEY CLUSTERED ([file_path] ASC, [collection_time_utc] ASC)
);


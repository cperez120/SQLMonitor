CREATE TABLE [dbo].[instance_details] (
    [sql_instance]           NVARCHAR (255) NOT NULL,
    [host_name]              NVARCHAR (255) NOT NULL,
    [collector_sql_instance] NVARCHAR (255) DEFAULT (CONVERT([nvarchar],serverproperty('MachineName'))) NULL,
    CONSTRAINT [pk_instance_details] PRIMARY KEY CLUSTERED ([sql_instance] ASC, [host_name] ASC),
    CONSTRAINT [fk_host_name] FOREIGN KEY ([host_name]) REFERENCES [dbo].[instance_hosts] ([host_name])
);


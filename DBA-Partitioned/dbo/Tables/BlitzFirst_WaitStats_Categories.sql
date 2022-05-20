CREATE TABLE [dbo].[BlitzFirst_WaitStats_Categories] (
    [WaitType]     NVARCHAR (60)  NOT NULL,
    [WaitCategory] NVARCHAR (128) NOT NULL,
    [Ignorable]    BIT            DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([WaitType] ASC)
);


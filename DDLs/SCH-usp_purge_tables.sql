IF DB_NAME() = 'master'
	raiserror ('Kindly execute all queries in [DBA] database', 20, -1) with log;
go

SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ANSI_WARNINGS ON;
SET NUMERIC_ROUNDABORT OFF;
SET ARITHABORT ON;
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'usp_purge_tables')
    EXEC ('CREATE PROC dbo.usp_purge_tables AS SELECT ''stub version, to be replaced''')
GO

ALTER PROCEDURE dbo.usp_purge_tables
AS 
BEGIN

	/*
		Version:		1.0.0
		Date:			2022-07-01

		EXEC dbo.usp_purge_tables
	*/
	SET NOCOUNT ON; 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	declare @c_table_name sysname;
	declare @c_date_key sysname;
	declare @c_retention_days smallint;
	declare @c_purge_row_size int;
	declare @sql nvarchar(max);
	declare @err_message nvarchar(2000);

	declare cur_purge_tables cursor local forward_only for
		select table_name, date_key, retention_days, purge_row_size from dbo.purge_table;

	open cur_purge_tables;
	fetch next from cur_purge_tables into @c_table_name, @c_date_key, @c_retention_days, @c_purge_row_size;

	while @@FETCH_STATUS = 0
	begin
		print 'Processing table '+@c_table_name;

		set @sql = '
		DECLARE @r INT;
	
		SET @r = 1;
		while @r > 0
		begin
			delete top ('+convert(varchar,@c_purge_row_size)+') pt
			from '+@c_table_name+' pt
			where '+@c_date_key+' < dateadd(day,-'+convert(varchar,@c_retention_days)+',cast(getdate() as date));

			set @r = @@ROWCOUNT;
		end
		'
		begin try
			exec (@sql);
			update dbo.purge_table set latest_purge_datetime = SYSDATETIME() where table_name = @c_table_name;
		end try
		begin catch
			set @err_message = isnull(@err_message,'') + char(10) + 'Error while purging table '+@c_table_name+'.'+char(10)+ ERROR_MESSAGE()+char(10);
		end catch
		fetch next from cur_purge_tables into @c_table_name, @c_date_key, @c_retention_days, @c_purge_row_size;
	end
	close cur_purge_tables;
	deallocate cur_purge_tables;

	if @err_message is not null
    raiserror (@err_message, 20, -1) with log;
END
GO

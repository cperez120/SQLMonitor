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

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'usp_partition_maintenance')
    EXEC ('CREATE PROC dbo.usp_partition_maintenance AS SELECT ''stub version, to be replaced''')
GO

ALTER PROCEDURE dbo.usp_partition_maintenance @step varchar(100) = null
AS 
BEGIN

	/*
		Version:		1.0.0
		Date:			2022-07-09

		EXEC dbo.usp_partition_maintenance
	*/
	SET NOCOUNT ON; 
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET QUOTED_IDENTIFIER ON;
	SET DEADLOCK_PRIORITY HIGH;

	declare @err_message nvarchar(2000);
	declare @current_step_name varchar(50);
	declare @current_boundary_value datetime2;
	declare @target_boundary_value datetime2; /* last day of new quarter */
	declare @current_time datetime2;
	declare @partition_boundary datetime2;

	if @step is not null and @step not in ('add_datetime2_partition','add_datetime_partition','remove_datetime2_partition','remove_datetime_partition')
		THROW 50000, '@recipients is mandatory parameter', 1;

	set @current_step_name = 'add_datetime2_partition'
	if @step is null or @step = @current_step_name
	begin
		begin try
			set @current_time = (case when sysdatetime() > sysutcdatetime() then sysdatetime() else sysutcdatetime() end);
			set @target_boundary_value = DATEADD (dd, -1, DATEADD(qq, DATEDIFF(qq, 0, @current_time) +2, 0));

			select top 1 @current_boundary_value = convert(datetime2,prv.value)
			from sys.partition_range_values prv
			join sys.partition_functions pf on pf.function_id = prv.function_id
			where pf.name = 'pf_dba'
			order by prv.value desc;

			if(@current_boundary_value is null or @current_boundary_value < @current_time )
			begin
				select 'Error - @current_boundary_value is NULL or its previous to current time.' as [Result-Of-Boundary-Check];
				set @current_boundary_value = dateadd(hour,datediff(hour,convert(date,@current_time),@current_time),cast(convert(date,@current_time)as datetime2));
			end
			select [@current_boundary_value] = @current_boundary_value, [@target_boundary_value] = @target_boundary_value;

			while (@current_boundary_value < @target_boundary_value)
			begin
				set @current_boundary_value = DATEADD(hour,1,@current_boundary_value);
				--print @current_boundary_value
				alter partition scheme ps_dba next used [primary];
				alter partition function pf_dba() split range (@current_boundary_value);	
			end
		end try
		begin catch
			set @err_message = isnull(@err_message,'') + char(10) + 'Error in step ['+@current_step_name+'.'+char(10)+ ERROR_MESSAGE()+char(10);
		end catch
	end

	set @current_step_name = 'add_datetime_partition'
	if @step is null or @step = @current_step_name
	begin
		begin try
			set @current_time = (case when getdate() > getutcdate() then getdate() else getutcdate() end);
			set @target_boundary_value = DATEADD (dd, -1, DATEADD(qq, DATEDIFF(qq, 0, @current_time) +2, 0));

			select top 1 @current_boundary_value = convert(datetime,prv.value)
			from sys.partition_range_values prv
			join sys.partition_functions pf on pf.function_id = prv.function_id
			where pf.name = 'pf_dba_datetime'
			order by prv.value desc;

			if(@current_boundary_value is null or @current_boundary_value < @current_time )
			begin
				select 'Error - @current_boundary_value is NULL or its previous to current time.';
				set @current_boundary_value = dateadd(hour,datediff(hour,convert(date,@current_time),@current_time),cast(convert(date,@current_time)as datetime));
			end
			select [@current_boundary_value] = @current_boundary_value, [@target_boundary_value] = @target_boundary_value;

			while (@current_boundary_value < @target_boundary_value)
			begin
				set @current_boundary_value = DATEADD(hour,1,@current_boundary_value);
				--print @current_boundary_value
				alter partition scheme ps_dba_datetime next used [primary];
				alter partition function pf_dba_datetime() split range (@current_boundary_value);	
			end
		end try
		begin catch
			set @err_message = isnull(@err_message,'') + char(10) + 'Error in step ['+@current_step_name+'.'+char(10)+ ERROR_MESSAGE()+char(10);
		end catch
	end

	set @current_step_name = 'remove_datetime2_partition'
	if @step is null or @step = @current_step_name
	begin
		begin try			
			set @target_boundary_value = DATEADD(mm,DATEDIFF(mm,0,GETDATE())-3,0);

			declare cur_boundaries cursor local fast_forward for
					select convert(datetime2,prv.value) as boundary_value
					from sys.partition_range_values prv
					join sys.partition_functions pf on pf.function_id = prv.function_id
					where pf.name = 'pf_dba' and convert(datetime2,prv.value) < @target_boundary_value
					order by prv.value asc;

			open cur_boundaries;
			fetch next from cur_boundaries into @partition_boundary;
			while @@FETCH_STATUS = 0
			begin
				--print @partition_boundary
				alter partition function pf_dba() merge range (@partition_boundary);

				fetch next from cur_boundaries into @partition_boundary;
			end
			close cur_boundaries
			deallocate cur_boundaries;
		end try
		begin catch
			set @err_message = isnull(@err_message,'') + char(10) + 'Error in step ['+@current_step_name+'.'+char(10)+ ERROR_MESSAGE()+char(10);
		end catch
	end

	set @current_step_name = 'remove_datetime_partition'
	if @step is null or @step = @current_step_name
	begin
		begin try
			set @target_boundary_value = DATEADD(mm,DATEDIFF(mm,0,GETDATE())-3,0);

			declare cur_boundaries cursor local fast_forward for
					select convert(datetime,prv.value) as boundary_value
					from sys.partition_range_values prv
					join sys.partition_functions pf on pf.function_id = prv.function_id
					where pf.name = 'pf_dba_datetime' and convert(datetime,prv.value) < @target_boundary_value
					order by prv.value asc;

			open cur_boundaries;
			fetch next from cur_boundaries into @partition_boundary;
			while @@FETCH_STATUS = 0
			begin
				--print @partition_boundary
				alter partition function pf_dba_datetime() merge range (@partition_boundary);

				fetch next from cur_boundaries into @partition_boundary;
			end
			CLOSE cur_boundaries
			DEALLOCATE cur_boundaries;
		end try
		begin catch
			set @err_message = isnull(@err_message,'') + char(10) + 'Error in step ['+@current_step_name+'.'+char(10)+ ERROR_MESSAGE()+char(10);
		end catch
	end

	if @err_message is not null
		throw 50000, @err_message, 1;
END
GO

declare @login nvarchar(125) = suser_name();

EXEC sp_WhoIsActive @get_outer_command = 1, @get_task_info=2 --,@get_avg_time=1,
					--,@find_block_leaders=1 , @get_additional_info=1
					--,@get_transaction_info=1 , @get_task_info=2, @get_additional_info=1, 	
					--,@get_full_inner_text=1
					--,@get_locks=1
					--,@get_plans=1
					--,@sort_order = '[CPU] DESC'					
					--,@filter_type = 'login' ,@filter = 'E84947'
					--,@filter_type = 'program' ,@filter = 'ODBC|risktrd|risk_master_write_prod|/proj/risk/adhocRuns/Risk_26520_24.py'

					--,@filter_type = 'database' ,@filter = 'security_master'
					--,@sort_order = '[reads] desc'

--select * from sys.configurations c
--where c.name like '%time%'
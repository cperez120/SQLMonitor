/*	https://stackoverflow.com/a/4975299
	https://sqldatapartners.com/2021/09/15/episode-233-scriptdom/
	How to normalize SQL Text similar to tools like ClearTrace, RML Utilities

	Path of assembly file
	SQLMonitor\SQLExternalFunctions\bin\Debug\SQLExternalFunctions.dll
*/

C:\SQLMonitor\SQLMonitor\ClassLibrarySQL.dll
C:\SQLMonitor\SQLMonitor\Microsoft.SqlServer.TransactSql.ScriptDom.dll
go

--USE master;
--GO
--CREATE ASYMMETRIC KEY ClassLibrarySQLKey FROM EXECUTABLE FILE = 'C:\SQLMonitor\SQLMonitor\ClassLibrarySQL.dll';
--GO
--USE master;
--GO
--CREATE LOGIN ClassLibrarySQLKeyLogin FROM ASYMMETRIC KEY ClassLibrarySQLKey;
--GO
--USE master;
--GO
--GRANT UNSAFE ASSEMBLY TO ClassLibrarySQLKeyLogin;
--GO
--USE DBA_Admin;
--GO
--CREATE USER ClassLibrarySQLKeyLogin FOR LOGIN ClassLibrarySQLKeyLogin;
--GO
--USE master;
--GO
--CREATE ASYMMETRIC KEY TransactSql FROM EXECUTABLE FILE = 'C:\SQLMonitor\SQLMonitor\Microsoft.SqlServer.TransactSql.ScriptDom.dll';
--GO
--USE master;
--GO
--CREATE LOGIN TransactSqlLogin FROM ASYMMETRIC KEY TransactSql;
--GO
--USE master;
--GO
--GRANT UNSAFE ASSEMBLY TO TransactSqlLogin;
--GO
--USE DBA_Admin;
--GO
--CREATE USER TransactSqlLogin FOR LOGIN TransactSqlLogin;
--GO
--CREATE ASSEMBLY ClassLibrarySQL FROM 'C:\SQLMonitor\SQLMonitor\ClassLibrarySQL.dll' WITH PERMISSION_SET = UNSAFE;
--GO
--CREATE FUNCTION sqlReplace(@inputOne NVARCHAR(max),@compatLevel int,@caseSensitive bit)
--RETURNS NVARCHAR(max) WITH EXECUTE AS CALLER, RETURNS NULL ON NULL INPUT
--AS
--EXTERNAL NAME [ClassLibrarySQL].[ClassLibrarySQL.StringOp].[sqlsig]
--GO
--EXEC sp_configure 'show advanced options', 1
--RECONFIGURE;
--EXEC sp_configure 'clr strict security', 0;
--RECONFIGURE;
--Go
--EXEC sp_configure 'clr enabled', 1;
--RECONFIGURE;

-- select sqlsig = dbo.sqlReplace('exec sp_WhoIsActive 110',150,0)

declare @c_sql_text nvarchar(max);
declare cur_rows cursor local fast_forward for
	select top 100 sql_text
	from DBA_Admin.dbo.resource_consumption rc
	where rc.event_time between dateadd(hour,-1,getdate()) and getdate()
	order by row_id;

open cur_rows;
fetch next from cur_rows into @c_sql_text;
while @@fetch_status = 0
begin
	select convert(xml,(select @c_sql_text for xml path ('query'))) as [sql_text-2-normalize];
	begin try
		select sqlsig = dbo.sqlReplace(@c_sql_text,150,0);
	end try
	begin catch
		select error_message() as err_Message;
	end catch
	fetch next from cur_rows into @c_sql_text;
end
close cur_rows
deallocate cur_rows
go





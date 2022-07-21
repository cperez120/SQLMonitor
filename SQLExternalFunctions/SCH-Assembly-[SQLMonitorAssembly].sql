/*	https://stackoverflow.com/a/4975299
	How to normalize SQL Text similar to tools like ClearTrace, RML Utilities

	Path of assembly file
	SQLMonitor\SQLExternalFunctions\bin\Debug\SQLExternalFunctions.dll
*/

EXEC sp_configure 'show advanced options', 1
RECONFIGURE;
EXEC sp_configure 'clr strict security', 0;
RECONFIGURE;
Go
EXEC sp_configure 'clr enabled', 1
go
RECONFIGURE
go
EXEC sp_configure 'clr enabled'
go

Create Assembly SQLMonitorAssembly from 'C:\SQLMonitor\SQLExternalFunctions.dll'
go

CREATE FUNCTION sql_signature(@inputOne NVARCHAR(max))
RETURNS NVARCHAR(max) WITH EXECUTE AS CALLER, RETURNS NULL ON NULL INPUT
AS
EXTERNAL NAME [SQLMonitorAssembly].[SQLExternalFunctions.SQLExternalFunctions].[sqlsig]
GO

--SELECT dbo.sql_signature('pramod j');
go




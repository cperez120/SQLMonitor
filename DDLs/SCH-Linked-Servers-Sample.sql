USE [master]
GO

EXEC master.dbo.sp_addlinkedserver @server = N'SqlPractice', @srvproduct=N'', @provider=N'SQLNCLI', @datasrc=N'SqlPractice', @catalog=N'DBA'

EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'SqlPractice',@useself=N'False',@locallogin=NULL,@rmtuser=N'grafana',@rmtpassword='grafana'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlPractice', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlPractice', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlPractice', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlPractice', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlPractice', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlPractice', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlPractice', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlPractice', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlPractice', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'SqlPractice', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlPractice', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlPractice', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlPractice', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO



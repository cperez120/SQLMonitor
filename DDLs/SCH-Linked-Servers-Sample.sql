USE [master]
GO

EXEC master.dbo.sp_addlinkedserver @server = N'SqlDr3', @srvproduct=N'', @provider=N'SQLNCLI', @datasrc=N'SqlDr3', @catalog=N'DBA'

EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'SqlDr3',@useself=N'False',@locallogin=NULL,@rmtuser=N'grafana',@rmtpassword='grafana'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlDr3', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlDr3', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlDr3', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlDr3', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlDr3', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlDr3', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlDr3', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlDr3', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlDr3', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'SqlDr3', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlDr3', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlDr3', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlDr3', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO



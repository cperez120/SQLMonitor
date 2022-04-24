USE [master]
GO

EXEC master.dbo.sp_addlinkedserver @server = N'Demo', @srvproduct=N'', @provider=N'SQLNCLI', @datasrc=N'Demo', @catalog=N'DBA'

EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'Demo',@useself=N'False',@locallogin=NULL,@rmtuser=N'grafana',@rmtpassword='grafana'
GO

EXEC master.dbo.sp_serveroption @server=N'Demo', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'Demo', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'Demo', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'Demo', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'Demo', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'Demo', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'Demo', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'Demo', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'Demo', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'Demo', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'Demo', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'Demo', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'Demo', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO



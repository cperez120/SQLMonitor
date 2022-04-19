USE [master]
GO

EXEC master.dbo.sp_addlinkedserver @server = N'SqlProd-A', @srvproduct=N'', @provider=N'SQLNCLI', @datasrc=N'SqlProd-A', @catalog=N'DBA'

EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'SqlProd-A',@useself=N'False',@locallogin=NULL,@rmtuser=N'Grafana',@rmtpassword='Grafana'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlProd-A', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlProd-A', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlProd-A', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlProd-A', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlProd-A', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlProd-A', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlProd-A', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlProd-A', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlProd-A', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'SqlProd-A', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlProd-A', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlProd-A', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'SqlProd-A', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO



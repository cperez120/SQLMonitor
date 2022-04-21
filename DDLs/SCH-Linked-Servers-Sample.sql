USE [master]
GO

EXEC master.dbo.sp_addlinkedserver @server = N'Workstation', @srvproduct=N'', @provider=N'SQLNCLI', @datasrc=N'Workstation', @catalog=N'DBA'

EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'Workstation',@useself=N'False',@locallogin=NULL,@rmtuser=N'grafana',@rmtpassword='grafana'
GO

EXEC master.dbo.sp_serveroption @server=N'Workstation', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'Workstation', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'Workstation', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'Workstation', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'Workstation', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'Workstation', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'Workstation', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'Workstation', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'Workstation', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'Workstation', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'Workstation', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'Workstation', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'Workstation', @optname=N'remote proc transaction promotion', @optvalue=N'true'
GO



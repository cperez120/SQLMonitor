USE SQLDBATools
GO


select * from [dbo].[sdt_server_inventory] i
go


insert dbo.sdt_server_inventory
(server, friendly_name, sql_instance, ipv4, stability, priority)
select	server = '', 
		friendly_name = '', 
		sql_instance = '', 
		ipv4 = '',
		stability = 'PROD', 
		priority = 1
go

update dbo.sdt_server_inventory
set rdp_credential = ''
	,sql_credential = ''
where friendly_name = ''
go



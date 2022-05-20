
-- drop procedure usp_extended_results
create procedure usp_extended_results @processor_name nvarchar(500) = null output, @host_distribution nvarchar(500) = null output, @fqdn nvarchar(100) = null output
with execute as owner
as
begin
	set nocount on;
	
	-- Processor Name
	exec xp_instance_regread 'HKEY_LOCAL_MACHINE', 'HARDWARE\DESCRIPTION\System\CentralProcessor\0', 'ProcessorNameString', @value = @processor_name output;

	-- Windows Version
	EXEC xp_instance_regread 'HKEY_LOCAL_MACHINE', 'SOFTWARE\Microsoft\Windows NT\CurrentVersion', 'ProductName', @value = @host_distribution OUTPUT;

	-- FQDN
	EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE', 'SYSTEM\CurrentControlSet\services\Tcpip\Parameters', N'Domain', @fqdn OUTPUT;     
	SET @fqdn = Cast(SERVERPROPERTY('MachineName') as nvarchar) + '.' + @fqdn;
	
end

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_extended_results] TO [grafana]
    AS [dbo];


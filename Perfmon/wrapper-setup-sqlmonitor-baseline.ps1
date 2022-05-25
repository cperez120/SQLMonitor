#$LabCredential = Get-Credential -UserName 'Lab\SQLServices' -Message 'Angel Broking'
#$saAdmin = Get-Credential -UserName 'sa' -Message 'sa'
#$localAdmin = Get-Credential -UserName 'DEMO\Administrator' -Message 'Administrator'

cls
$params = @{
    SqlInstanceToBaseline = '192.168.56.31'
    DbaDatabase = 'DBA_Admin'
    DbaToolsFolderPath = 'D:\Softwares\dbatools'
    InventoryServer = '192.168.56.15'
    SqlCredential = $saAdmin
    WindowsCredential = $LabCredential
    #SkipSteps = @('11__CopyPerfmonFolder2Host','12__SetupPerfmonDataCollector','13__CreateJobCollectOSProcesses','14__CreateJobCollectPerfmonData','21__CreateJobUpdateSqlServerVersions','22__LinkedServerOnInventory')
    #StartAtStep = '8__usp_GetAllServerInfo'
    #StopAtStep = '22__GrafanaLogin'
}
D:\GitHub\SQLMonitor\Perfmon\setup-sqlmonitor-baseline.ps1 @Params #-Debug

#Get-DbaDbMailProfile -SqlInstance '192.168.56.31' -SqlCredential $personalCredential
#Copy-DbaDbMail -Source '192.168.56.15' -Destination '192.168.56.31' -SourceSqlCredential $personalCredential -DestinationSqlCredential $personalCredential # Lab
#Remove-DbaDbMailProfile -SqlInstance '192.168.56.31' -SqlCredential $personalCredential -Profile @('Server Configuration','intranet','NXT')
#Remove-DbaDbMailAccount -SqlInstance '192.168.56.31' -SqlCredential $personalCredential -Account @('intranet','NXT')
<#

Enable-PSRemoting -Force # run on remote machine
Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value * -Force # run on local machine
Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value 192.168.56.15 -Force
#Set-NetConnectionProfile -NetworkCategory Private # Execute this only if above command fails

Enter-PSSession -ComputerName '192.168.56.31' -Credential $localAdmin -Authentication Negotiate
Test-WSMan '192.168.56.31' -Credential $localAdmin -Authentication Negotiate


#>

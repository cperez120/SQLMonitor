#$LabCredential = Get-Credential -UserName 'Lab\SQLServices' -Message 'AD Account'
#$saAdmin = Get-Credential -UserName 'sa' -Message 'sa'
#$localAdmin = Get-Credential -UserName 'DEMO\Administrator' -Message 'Local Admin'
#Pa$$w0rd
cls
$params = @{
    SqlInstanceToBaseline = 'DEMO\SQL2019'
    DbaDatabase = 'DBA'
    DbaToolsFolderPath = 'F:\GitHub\dbatools'
    InventoryServer = 'SQLMonitor'
    #SqlCredential = $saAdmin
    #WindowsCredential = $LabCredential
    #SkipSteps = @('11__SetupPerfmonDataCollector','12__CreateJobCollectOSProcesses','13__CreateJobCollectPerfmonData')
    #StartAtStep = '8__usp_GetAllServerInfo'
    #StopAtStep = '22__GrafanaLogin'
}
F:\GitHub\SQLMonitor\Perfmon\setup-sqlmonitor-baseline.ps1 @Params #-Debug

#Get-DbaDbMailProfile -SqlInstance '192.168.56.31' -SqlCredential $personalCredential
#Copy-DbaDbMail -Source '192.168.56.15' -Destination '192.168.56.31' -SourceSqlCredential $personalCredential -DestinationSqlCredential $personalCredential # Lab
#Remove-DbaDbMailProfile -SqlInstance '192.168.56.31' -SqlCredential $personalCredential -Profile @('DBA')
#Remove-DbaDbMailAccount -SqlInstance '192.168.56.31' -SqlCredential $personalCredential -Account @('DBA')
<#

Enable-PSRemoting -Force # run on remote machine
Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value * -Force # run on local machine
Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value 192.168.56.15 -Force
#Set-NetConnectionProfile -NetworkCategory Private # Execute this only if above command fails

Enter-PSSession -ComputerName '192.168.56.31' -Credential $localAdmin -Authentication Negotiate
Test-WSMan '192.168.56.31' -Credential $localAdmin -Authentication Negotiate


#>

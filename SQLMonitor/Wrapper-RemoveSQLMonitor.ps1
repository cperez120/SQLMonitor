#$DomainCredential = Get-Credential -UserName 'Lab\SQLServices' -Message 'AD Account'
#$saAdmin = Get-Credential -UserName 'sa' -Message 'sa'
#$localAdmin = Get-Credential -UserName 'Administrator' -Message 'Local Admin'

cls
Import-Module dbatools;
$params = @{
    SqlInstanceToBaseline = 'Workstation\SQLEXPRESS'
    DbaDatabase = 'DBA'
    InventoryServer = 'SQLMonitor'
    RemoteSQLMonitorPath = 'C:\SQLMonitor'
    #SqlCredential = $saAdmin
    #WindowsCredential = $DomainCredential
    #SkipSteps = @("43__RemovePerfmonFilesFromDisk")
    #StartAtStep = '22__DropLogin_Grafana'
    #StopAtStep = '10__RemoveJob_UpdateSqlServerVersions'
    SkipDropTable = $true
    #SkipRemoveJob = $true
    #SkipDropProc = $true
    #SkipDropView = $true
    DryRun = $false
}
F:\GitHub\SQLMonitor\SQLMonitor\Remove-SQLMonitor.ps1 @Params #-Debug


#Get-DbaDbMailProfile -SqlInstance '192.168.56.31' -SqlCredential $personalCredential
#Copy-DbaDbMail -Source '192.168.56.15' -Destination '192.168.56.31' -SourceSqlCredential $personalCredential -DestinationSqlCredential $personalCredential # Lab
#New-DbaCredential -SqlInstance 'xy' -Identity $LabCredential.UserName -SecurePassword $LabCredential.Password -Force # -SqlCredential $SqlCredential -EnableException
#New-DbaAgentProxy -SqlInstance 'xy' -Name $LabCredential.UserName -ProxyCredential $LabCredential.UserName -SubSystem PowerShell,CmdExec
<#

Enable-PSRemoting -Force # run on remote machine
Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value * -Force # run on local machine
Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value 192.168.56.15 -Force
#Set-NetConnectionProfile -NetworkCategory Private # Execute this only if above command fails

Enter-PSSession -ComputerName '192.168.56.31' -Credential $localAdmin -Authentication Negotiate
Test-WSMan '192.168.56.31' -Credential $localAdmin -Authentication Negotiate


#>

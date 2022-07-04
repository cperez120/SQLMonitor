#$LabCredential = Get-Credential -UserName 'Lab\SQLServices' -Message 'AD Account'
#$saAdmin = Get-Credential -UserName 'sa' -Message 'sa'
#$localAdmin = Get-Credential -UserName 'DEMO\SQL2019\Administrator' -Message 'Local Admin'

cls
$params = @{
    SqlInstanceToBaseline = 'SqlPractice'
    DbaDatabase = 'DBA'
    DbaToolsFolderPath = 'F:\GitHub\dbatools'
    RemoteSQLMonitorPath = 'C:\SQLMonitor'
    InventoryServer = 'SQLMonitor'
    DbaGroupMailId = 'sqlagentservice@gmail.com'
    #SqlCredential = $saAdmin
    #WindowsCredential = $LabCredential
    #SkipSteps = @("11__SetupPerfmonDataCollector", "12__CreateJobCollectOSProcesses","13__CreateJobCollectPerfmonData")
    #StartAtStep = '8__usp_GetAllServerInfo'
    #StopAtStep = '21__WhoIsActivePartition'
    #DropCreatePowerShellJobs = $true
    #DryRun = $false
    #SkipRDPSessionSteps = $true
    #SkipPowerShellJobs = $true
    #SkipAllJobs = $true
}
F:\GitHub\SQLMonitor\SQLMonitor\Install-SQLMonitor.ps1 @Params #-Debug


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

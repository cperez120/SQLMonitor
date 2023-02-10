#$DomainCredential = Get-Credential -UserName 'Lab\SQLServices' -Message 'AD Account'
#$saAdmin = Get-Credential -UserName 'sa' -Message 'sa'
#$localAdmin = Get-Credential -UserName 'Administrator' -Message 'Local Admin'

cls
Import-Module dbatools;
$params = @{
    SqlInstanceToBaseline = 'Workstation'
    DbaDatabase = 'DBA'
    #HostName = 'Workstation'
    #RetentionDays = 7
    DbaToolsFolderPath = 'F:\GitHub\dbatools'
    #FirstResponderKitZipFile = 'F:\GitHub\SQL-Server-First-Responder-Kit-20221213main.zip'
    #RemoteSQLMonitorPath = 'C:\SQLMonitor'
    InventoryServer = 'SQLMonitor'
    InventoryDatabase = 'DBA'
    DbaGroupMailId = 'some_dba_mail_id@gmail.com'
    #SqlCredential = $personal
    #WindowsCredential = $DomainCredential
    <#
    SkipSteps = @(  "1__sp_WhoIsActive", "2__AllDatabaseObjects", "3__XEventSession",
                "4__FirstResponderKitObjects", "5__DarlingDataObjects", "6__sp_WhatIsRunning",
                "7__usp_GetAllServerInfo", "8__CopyDbaToolsModule2Host", "9__CopyPerfmonFolder2Host",
                "10__SetupPerfmonDataCollector", "11__CreateCredentialProxy", "12__CreateJobCollectDiskSpace",
                "13__CreateJobCollectOSProcesses", "14__CreateJobCollectPerfmonData", "15__CreateJobCollectWaitStats",
                "16__CreateJobCollectXEvents", "17__CreateJobCollectFileIOStats", "18__CreateJobPartitionsMaintenance",
                "19__CreateJobPurgeTables", "20__CreateJobRemoveXEventFiles", "21__CreateJobRunWhoIsActive",
                "22__CreateJobRunBlitzIndex", "23__CreateJobRunBlitzIndexWeekly", "24__CreateJobCollectMemoryClerks",
                "25__CreateJobUpdateSqlServerVersions", "26__CreateJobCheckInstanceAvailability", "27__CreateJobGetAllServerInfo",
                "28__WhoIsActivePartition", "29__BlitzIndexPartition", "30__EnablePageCompression",
                "31__GrafanaLogin", "32__LinkedServerOnInventory", "33__LinkedServerForDataDestinationInstance",
                "34__AlterViewsForDataDestinationInstance")
    #>
    #SkipSteps = @("21__CreateJobRemoveXEventFiles","32__LinkedServerForDataDestinationInstance")
    #StartAtStep = '1__sp_WhoIsActive'
    #StopAtStep = '32__AlterViewsForDataDestinationInstance'
    #DropCreatePowerShellJobs = $true
    #DryRun = $false
    #SkipRDPSessionSteps = $true
    #SkipPowerShellJobs = $true
    #SkipTsqlJobs = $true
    #SkipMailProfileCheck = $true
    #skipCollationCheck = $true
    #SkipWindowsAdminAccessTest = $true
    #SqlInstanceAsDataDestination = 'Workstation'
    #SqlInstanceForPowershellJobs = 'Workstation'
    #SqlInstanceForTsqlJobs = 'Workstation'
    #ConfirmValidationOfMultiInstance = $true
}
F:\GitHub\SQLMonitor\SQLMonitor\Install-SQLMonitor.ps1 @Params #-Debug

<#
$dropWhoIsActive = @"
if object_id('dbo.WhoIsActive_Staging') is not null
	drop table dbo.WhoIsActive_Staging;

if object_id('dbo.WhoIsActive') is not null
	drop table dbo.WhoIsActive;
"@;
F:\GitHub\SQLMonitor\SQLMonitor\Install-SQLMonitor.ps1 @Params -PreQuery $dropWhoIsActive
#>

# Get-Help F:\GitHub\SQLMonitor\SQLMonitor\Install-SQLMonitor.ps1 -ShowWindow
#Get-DbaDbMailProfile -SqlInstance '192.168.56.31' -SqlCredential $personalCredential
#Copy-DbaDbMail -Source '192.168.56.15' -Destination '192.168.56.31' -SourceSqlCredential $personalCredential -DestinationSqlCredential $personalCredential # Lab
#New-DbaCredential -SqlInstance 'xy' -Identity $LabCredential.UserName -SecurePassword $LabCredential.Password -Force # -SqlCredential $SqlCredential -EnableException
#New-DbaAgentProxy -SqlInstance 'xy' -Name $LabCredential.UserName -ProxyCredential $LabCredential.UserName -SubSystem PowerShell,CmdExec
<#

Enable-PSRemoting -Force -SkipNetworkProfileCheck # remote machine
Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value SQLMonitor.Lab.com -Concatenate -Force # remote machine
Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy
Set-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy -Value 1

# Incase 
#Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value * -Force # run on local machine
#Set-NetConnectionProfile -NetworkCategory Private # Execute this only if above command fails

Enter-PSSession -ComputerName '192.168.56.31' -Credential $localAdmin -Authentication Negotiate
Test-WSMan '192.168.56.31' -Credential $localAdmin -Authentication Negotiate


#>


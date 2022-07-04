[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)]
    $SqlInstanceToBaseline,

    [Parameter(Mandatory=$false)]
    $DbaDatabase,

    [Parameter(Mandatory=$false)]
    $SqlInstanceAsDataDestination,

    [Parameter(Mandatory=$false)]
    $SqlInstanceForDataCollectionJobs,

    [Parameter(Mandatory=$false)]
    $InventoryServer,

    [Parameter(Mandatory=$false)]
    $HostName,

    [Switch]$IsNonPartitioned,

    [Parameter(Mandatory=$false)]
    [String]$SQLMonitorPath,

    [Parameter(Mandatory=$true)]
    [String]$DbaToolsFolderPath,

    [Parameter(Mandatory=$true)]
    [String]$RemoteSQLMonitorPath,

    [Parameter(Mandatory=$false)]
    [String]$MailProfileFileName = "DatabaseMail_Using_GMail.sql",

    [Parameter(Mandatory=$false)]
    [String]$WhoIsActiveFileName = "SCH-sp_WhoIsActive_v12_00(Modified).sql",

    [Parameter(Mandatory=$false)]
    [String]$AllDatabaseObjectsFileName = "SCH-Create-All-Objects.sql",

    [Parameter(Mandatory=$false)]
    [String]$XEventSessionFileName = "SCH-Create-XEvents.sql",

    [Parameter(Mandatory=$false)]
    [String]$WhatIsRunningFileName = "SCH-sp_WhatIsRunning.sql",

    [Parameter(Mandatory=$false)]
    [String]$GetAllServerInfoFileName = "SCH-usp_GetAllServerInfo.sql",

    [Parameter(Mandatory=$false)]
    [String]$WhoIsActivePartitionFileName = "SCH-WhoIsActive-Partitioning.sql",

    [Parameter(Mandatory=$false)]
    [String]$GrafanaLoginFileName = "grafana-login.sql",

    [Parameter(Mandatory=$false)]
    [String]$CollectOSProcessesFileName = "SCH-Job-[(dba) Collect-OSProcesses].sql",

    [Parameter(Mandatory=$false)]
    [String]$CollectPerfmonDataFileName = "SCH-Job-[(dba) Collect-PerfmonData].sql",

    [Parameter(Mandatory=$false)]
    [String]$CollectWaitStatsFileName = "SCH-Job-[(dba) Collect-WaitStats].sql",

    [Parameter(Mandatory=$false)]
    [String]$CollectXEventsFileName = "SCH-Job-[(dba) Collect-XEvents].sql",

    [Parameter(Mandatory=$false)]
    [String]$PartitionsMaintenanceFileName = "SCH-Job-[(dba) Partitions-Maintenance].sql",

    [Parameter(Mandatory=$false)]
    [String]$PurgeTablesFileName = "SCH-Job-[(dba) Purge-Tables].sql",

    [Parameter(Mandatory=$false)]
    [String]$RemoveXEventFilesFileName = "SCH-Job-[(dba) Remove-XEventFiles].sql",

    [Parameter(Mandatory=$false)]
    [String]$RunWhoIsActiveFileName = "SCH-Job-[(dba) Run-WhoIsActive].sql",

    [Parameter(Mandatory=$false)]
    [String]$UpdateSqlServerVersionsFileName = "SCH-Job-[(dba) Update-SqlServerVersions].sql",

    [Parameter(Mandatory=$false)]
    [String]$LinkedServerOnInventoryFileName = "SCH-Linked-Servers-Sample.sql",

    [Parameter(Mandatory=$false)]
    [String]$TestWindowsAdminAccessFileName = "SCH-Job-[(dba) Test-WindowsAdminAccess].sql",

    [Parameter(Mandatory=$true)]
    [String[]]$DbaGroupMailId,

    [Parameter(Mandatory=$false)]
    [ValidateSet("1__sp_WhoIsActive", "2__AllDatabaseObjects", "3__XEventSession",
                "4__FirstResponderKitObjects", "5__DarlingDataObjects", "6__OlaHallengrenSolutionObjects",
                "7__sp_WhatIsRunning", "8__usp_GetAllServerInfo", "9__CopyDbaToolsModule2Host",
                "10__CopyPerfmonFolder2Host", "11__SetupPerfmonDataCollector", "12__CreateJobCollectOSProcesses",
                "13__CreateJobCollectPerfmonData", "14__CreateJobCollectWaitStats", "15__CreateJobCollectXEvents",
                "16__CreateJobPartitionsMaintenance", "17__CreateJobPurgeTables", "18__CreateJobRemoveXEventFiles",
                "19__CreateJobRunWhoIsActive", "20__CreateJobUpdateSqlServerVersions", "21__WhoIsActivePartition",
                "22__GrafanaLogin", "23__LinkedServerOnInventory")]
    [String]$StartAtStep = "1__sp_WhoIsActive",

    [Parameter(Mandatory=$false)]
    [ValidateSet("1__sp_WhoIsActive", "2__AllDatabaseObjects", "3__XEventSession",
                "4__FirstResponderKitObjects", "5__DarlingDataObjects", "6__OlaHallengrenSolutionObjects",
                "7__sp_WhatIsRunning", "8__usp_GetAllServerInfo", "9__CopyDbaToolsModule2Host",
                "10__CopyPerfmonFolder2Host", "11__SetupPerfmonDataCollector", "12__CreateJobCollectOSProcesses",
                "13__CreateJobCollectPerfmonData", "14__CreateJobCollectWaitStats", "15__CreateJobCollectXEvents",
                "16__CreateJobPartitionsMaintenance", "17__CreateJobPurgeTables", "18__CreateJobRemoveXEventFiles",
                "19__CreateJobRunWhoIsActive", "20__CreateJobUpdateSqlServerVersions", "21__WhoIsActivePartition",
                "22__GrafanaLogin", "23__LinkedServerOnInventory")]
    [String[]]$SkipSteps,

    [Parameter(Mandatory=$false)]
    [ValidateSet("1__sp_WhoIsActive", "2__AllDatabaseObjects", "3__XEventSession",
                "4__FirstResponderKitObjects", "5__DarlingDataObjects", "6__OlaHallengrenSolutionObjects",
                "7__sp_WhatIsRunning", "8__usp_GetAllServerInfo", "9__CopyDbaToolsModule2Host",
                "10__CopyPerfmonFolder2Host", "11__SetupPerfmonDataCollector", "12__CreateJobCollectOSProcesses",
                "13__CreateJobCollectPerfmonData", "14__CreateJobCollectWaitStats", "15__CreateJobCollectXEvents",
                "16__CreateJobPartitionsMaintenance", "17__CreateJobPurgeTables", "18__CreateJobRemoveXEventFiles",
                "19__CreateJobRunWhoIsActive", "20__CreateJobUpdateSqlServerVersions", "21__WhoIsActivePartition",
                "22__GrafanaLogin", "23__LinkedServerOnInventory")]
    [String]$StopAtStep,

    [Parameter(Mandatory=$false)]
    [PSCredential]$SqlCredential,

    [Parameter(Mandatory=$false)]
    [PSCredential]$WindowsCredential,

    [Parameter(Mandatory=$false)]
    [bool]$DropCreatePowerShellJobs = $false,

    [Parameter(Mandatory=$false)]
    [bool]$DryRun = $false
)

# All Steps
$AllSteps = @(  "1__sp_WhoIsActive", "2__AllDatabaseObjects", "3__XEventSession",
                "4__FirstResponderKitObjects", "5__DarlingDataObjects", "6__OlaHallengrenSolutionObjects",
                "7__sp_WhatIsRunning", "8__usp_GetAllServerInfo", "9__CopyDbaToolsModule2Host",
                "10__CopyPerfmonFolder2Host", "11__SetupPerfmonDataCollector", "12__CreateJobCollectOSProcesses",
                "13__CreateJobCollectPerfmonData", "14__CreateJobCollectWaitStats", "15__CreateJobCollectXEvents",
                "16__CreateJobPartitionsMaintenance", "17__CreateJobPurgeTables", "18__CreateJobRemoveXEventFiles",
                "19__CreateJobRunWhoIsActive", "20__CreateJobUpdateSqlServerVersions", "21__WhoIsActivePartition",
                "22__GrafanaLogin", "23__LinkedServerOnInventory")

cls
$startTime = Get-Date
$ErrorActionPreference = "Stop"

if($SqlInstanceToBaseline -eq '.' -or $SqlInstanceToBaseline -eq 'localhost') {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "'localhost' or '.' are not validate SQLInstance names." | Write-Host -ForegroundColor Red
    Write-Error "Stop here. Fix above issue."
}

"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'START:', "Working on server [$SqlInstanceToBaseline] with [$DbaDatabase] database.`n" | Write-Host -ForegroundColor Yellow

# Evaluate path of SQLMonitor folder
if( (-not [String]::IsNullOrEmpty($PSScriptRoot)) -or ((-not [String]::IsNullOrEmpty($SQLMonitorPath)) -and $(Test-Path $SQLMonitorPath)) ) {
    if([String]::IsNullOrEmpty($SQLMonitorPath)) {
        $SQLMonitorPath = $(Split-Path $PSScriptRoot -Parent)
    }
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$SQLMonitorPath = '$SQLMonitorPath'"
}
else {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Kindly provide 'SQLMonitorPath' parameter value" | Write-Host -ForegroundColor Red
    Write-Error "Stop here. Fix above issue."
}

# Set $SqlInstanceAsDataDestination same as $SqlInstanceToBaseline if NULL
if([String]::IsNullOrEmpty($SqlInstanceAsDataDestination)) {
    $SqlInstanceAsDataDestination = $SqlInstanceToBaseline
}

# Set $SqlInstanceForDataCollectionJobs same as $SqlInstanceToBaseline if NULL
if([String]::IsNullOrEmpty($SqlInstanceForDataCollectionJobs)) {
    $SqlInstanceForDataCollectionJobs = $SqlInstanceToBaseline
}

# Set windows credential if valid AD credential is provided as SqlCredential
if( [String]::IsNullOrEmpty($WindowsCredential) -and (-not [String]::IsNullOrEmpty($SqlCredential)) -and $SqlCredential.UserName -like "*\*" ) {
    $WindowsCredential = $SqlCredential
}

# Remove end trailer of '\'
if($RemoteSQLMonitorPath.EndsWith('\')) {
    $RemoteSQLMonitorPath = $RemoteSQLMonitorPath.TrimEnd('\')
}

"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$SqlInstanceToBaseline = [$SqlInstanceToBaseline]"
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$SqlInstanceForDataCollectionJobs = [$SqlInstanceForDataCollectionJobs]"
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$SqlInstanceAsDataDestination = [$SqlInstanceAsDataDestination]"

"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$SqlCredential => "
$SqlCredential | ft -AutoSize
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$WindowsCredential => "
$WindowsCredential | ft -AutoSize

# Construct File Path Variables
$ddlPath = Join-Path $SQLMonitorPath "DDLs"
$psScriptPath = Join-Path $SQLMonitorPath "SQLMonitor"

$mailProfileFilePath = "$ddlPath\$MailProfileFileName"
$WhoIsActiveFilePath = "$ddlPath\$WhoIsActiveFileName"
$AllDatabaseObjectsFilePath = "$ddlPath\$AllDatabaseObjectsFileName"
$XEventSessionFilePath = "$ddlPath\$XEventSessionFileName"
$WhatIsRunningFilePath = "$ddlPath\$WhatIsRunningFileName"
$GetAllServerInfoFilePath = "$ddlPath\$GetAllServerInfoFileName"
$WhoIsActivePartitionFilePath = "$ddlPath\$WhoIsActivePartitionFileName"
$GrafanaLoginFilePath = "$ddlPath\$GrafanaLoginFileName"
$CollectOSProcessesFilePath = "$ddlPath\$CollectOSProcessesFileName"
$CollectPerfmonDataFilePath = "$ddlPath\$CollectPerfmonDataFileName"
$CollectWaitStatsFilePath = "$ddlPath\$CollectWaitStatsFileName"
$CollectXEventsFilePath = "$ddlPath\$CollectXEventsFileName"
$PartitionsMaintenanceFilePath = "$ddlPath\$PartitionsMaintenanceFileName"
$PurgeTablesFilePath = "$ddlPath\$PurgeTablesFileName"
$RemoveXEventFilesFilePath = "$ddlPath\$RemoveXEventFilesFileName"
$RunWhoIsActiveFilePath = "$ddlPath\$RunWhoIsActiveFileName"
$UpdateSqlServerVersionsFilePath = "$ddlPath\$UpdateSqlServerVersionsFileName"
$LinkedServerOnInventoryFilePath = "$ddlPath\$LinkedServerOnInventoryFileName"
$WhoIsActivePartitionFilePath = "$ddlPath\$WhoIsActivePartitionFileName"
$TestWindowsAdminAccessFilePath = "$ddlPath\$TestWindowsAdminAccessFileName"

"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$ddlPath = '$ddlPath'"
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$psScriptPath = '$psScriptPath'"

"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Import dbatools module.."
Import-Module dbatools
Import-Module SqlServer

# Compute steps to execute
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Compute Steps to execute.."
[int]$StartAtStepNumber = $StartAtStep -replace "__\w+", ''
[int]$StopAtStepNumber = $StopAtStep -replace "__\w+", ''
if($StopAtStepNumber -eq 0) {
    $StopAtStepNumber = $AllSteps.Count+1
}
$Steps2Execute = @()
$Steps2ExecuteRaw = @()
if(-not [String]::IsNullOrEmpty($SkipSteps)) {
    $Steps2ExecuteRaw += Compare-Object -ReferenceObject $AllSteps -DifferenceObject $SkipSteps | Select-Object -ExpandProperty InputObject
}
else {
    $Steps2ExecuteRaw += $AllSteps
}

$Steps2Execute += $Steps2ExecuteRaw | ForEach-Object { 
                            $currentStepNumber = [int]$($_ -replace "__\w+", ''); 
                            if($currentStepNumber -ge $StartAtStepNumber -and $currentStepNumber -le $StopAtStepNumber) {
                                $_}
                        }
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$StartAtStep -> $StartAtStep.."
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$StopAtStep -> $StopAtStep.."
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Total steps to execute -> $($Steps2Execute.Count)."


# Get Server Info
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Fetching basic server info.."
$sqlServerInfo = @"
select	default_domain() as [domain],
		--[ip] = CONNECTIONPROPERTY('local_net_address'),
		[@@SERVERNAME] = @@SERVERNAME,
		[MachineName] = serverproperty('MachineName'),
		[ServerName] = serverproperty('ServerName'),
		[host_name] = SERVERPROPERTY('ComputerNamePhysicalNetBIOS'),
		SERVERPROPERTY('ProductVersion') AS ProductVersion,
		[service_name_str] = servicename,
		[service_name] = case	when @@servicename = 'MSSQLSERVER' and servicename like 'SQL Server (%)' then 'MSSQLSERVER'
								when @@servicename = 'MSSQLSERVER' and servicename like 'SQL Server Agent (%)' then 'SQLSERVERAGENT'
								when @@servicename <> 'MSSQLSERVER' and servicename like 'SQL Server (%)' then 'MSSQL$'+@@servicename
								when @@servicename <> 'MSSQLSERVER' and servicename like 'SQL Server Agent (%)' then 'SQLAgent'+@@servicename
								else 'MSSQL$'+@@servicename end,
        service_account,
		SERVERPROPERTY('Edition') AS Edition
from sys.dm_server_services 
where servicename like 'SQL Server (%)'
or servicename like 'SQL Server Agent (%)'
"@
try {
    $sqlServerServicesInfo = Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Query $sqlServerInfo -SqlCredential $SqlCredential -EnableException
    $sqlServerInfo = $sqlServerServicesInfo | Where-Object {$_.service_name_str -like "SQL Server (*)"}
    $sqlServerAgentInfo = $sqlServerServicesInfo | Where-Object {$_.service_name_str -like "SQL Server Agent (*)"}
    $sqlServerServicesInfo | Format-Table -AutoSize
}
catch {
    $errMessage = $_
    
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "SQL Connection to [$SqlInstanceToBaseline] failed."
    if([String]::IsNullOrEmpty($SqlCredential)) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Kindly provide SqlCredentials." | Write-Host -ForegroundColor Red
    } else {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Provided SqlCredentials seems to be NOT working." | Write-Host -ForegroundColor Red
    }
    Write-Error "Stop here. Fix above issue."
}

# Service Account and Access Validation
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Validate for WindowsCredential if SQL Service Accounts are non-priviledged.."
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$TestWindowsAdminAccessFilePath = '$TestWindowsAdminAccessFilePath'"
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating & executing job [(dba) Test-WindowsAdminAccess] on [$SqlInstanceForDataCollectionJobs].."
$sqlTestWindowsAdminAccessFilePath = [System.IO.File]::ReadAllText($TestWindowsAdminAccessFilePath)
Invoke-DbaQuery -SqlInstance $SqlInstanceForDataCollectionJobs -Database msdb -Query $sqlTestWindowsAdminAccessFilePath -SqlCredential $SqlCredential -EnableException


$testWindowsAdminAccessJobHistory = @()
$loopStartTime = Get-Date
$sleepDurationSeconds = 5
$loopTotalDurationThresholdSeconds = 300    
    
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Fetching execution history for job [(dba) Test-WindowsAdminAccess] on [$SqlInstanceForDataCollectionJobs].."
while ($testWindowsAdminAccessJobHistory.Count -eq 0 -and $( (New-TimeSpan $loopStartTime $(Get-Date)).TotalSeconds -le $loopTotalDurationThresholdSeconds ) )
{
    $testWindowsAdminAccessJobHistory += Get-DbaAgentJobHistory -SqlInstance $SqlInstanceForDataCollectionJobs -Job '(dba) Test-WindowsAdminAccess' `
                                                -ExcludeJobSteps -SqlCredential $SqlCredential -EnableException

    if($testWindowsAdminAccessJobHistory.Count -eq 0) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Wait for $sleepDurationSeconds seconds as the job might be running.."
        Start-Sleep -Seconds $sleepDurationSeconds
    }
}

if($testWindowsAdminAccessJobHistory.Count -eq 0) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Status of job [(dba) Test-WindowsAdminAccess] on [$SqlInstanceForDataCollectionJobs] could not be fetched on time. Kindly validate." | Write-Host -ForegroundColor Red
    "STOP and check above error message" | Write-Error
}
else {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "[(dba) Test-WindowsAdminAccess] Job history => '$($testWindowsAdminAccessJobHistory.Message)'."
    $testWindowsAdminAccessJobHistory | Format-Table -AutoSize
}

$hasWindowsAdminAccess = $false
if($testWindowsAdminAccessJobHistory.Status -ne 'Succeeded') {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "SQL Agent service account [$($sqlServerAgentInfo.service_account)] DO NOT have admin access at windows."
} else {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "SQL Agent service account [$($sqlServerAgentInfo.service_account)] has admin access at windows."
    $hasWindowsAdminAccess = $true
}

"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Remmove test job [(dba) Test-WindowsAdminAccess].."
Invoke-DbaQuery -SqlInstance $SqlInstanceForDataCollectionJobs -Database msdb -Query "EXEC msdb.dbo.sp_delete_job @job_name=N'(dba) Test-WindowsAdminAccess'" -SqlCredential $SqlCredential -EnableException


$requireProxy = $(-not $hasWindowsAdminAccess)
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$hasWindowsAdminAccess = $hasWindowsAdminAccess"
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$requireProxy = $requireProxy"

if($requireProxy -and [String]::IsNullOrEmpty($WindowsCredential)) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Kindly provide WindowsCredential to create SQL Agent Job Proxy." | Write-Host -ForegroundColor Red
    "STOP and check above error message" | Write-Error
}

# Set Partition Flag
$IsNonPartitioned = $false

# Extract Version Info
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Extract Major & Minor Version of SQL Server.."
if($sqlServerInfo.ProductVersion -match "(?'MajorVersion'\d+)\.\d+\.(?'MinorVersion'\d+)\.\d+")
{
    [int]$MajorVersion = $Matches['MajorVersion']
    [int]$MinorVersion = $Matches['MinorVersion']
    if($sqlServerInfo.Edition -like 'Standard*') 
    {
        if($MajorVersion -lt 13) {
            $IsNonPartitioned = $true
        }
        elseif ($MajorVersion -eq 13 -and $MinorVersion -lt 4000) {
            $IsNonPartitioned = $true
        }
    }
}

# Fetch HostName from SqlInstance if NULL
if([String]::IsNullOrEmpty($HostName)) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Extract HostName of SQL Server Instance.."
    $HostName = $sqlServerInfo.host_name;
}

# Setup PSSession on Host
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Create PSSession for host [$HostName].."
$ssnHostName = $HostName
if (-not (Test-Connection -ComputerName $HostName -Quiet -Count 1)) {
    $ssnHostName = $SqlInstanceToBaseline
}
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$ssnHostName => '$ssnHostName'"
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Domain of SqlInstance being baselined => [$($sqlServerInfo.domain)]"
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Domain of current host => [$($env:USERDOMAIN)]"

$ssn = $null
$errVariables = @()

# First Attempt without Any credentials
try {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Trying for PSSession on [$ssnHostName] normally.."
        $ssn = New-PSSession -ComputerName $ssnHostName 
    }
catch { $errVariables += $_ }

# Second Attempt for Trusted Cross Domains
if( [String]::IsNullOrEmpty($ssn) ) {
    try { 
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Trying for PSSession on [$ssnHostName] assuming cross domain.."
        $ssn = New-PSSession -ComputerName $ssnHostName -Authentication Negotiate 
    }
    catch { $errVariables += $_ }
}

# 3rd Attempt with Credentials
if( [String]::IsNullOrEmpty($ssn) -and (-not [String]::IsNullOrEmpty($WindowsCredential)) ) {
    try {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Attemping PSSession for [$ssnHostName] using provided WindowsCredentials.."
        $ssn = New-PSSession -ComputerName $ssnHostName -Credential $WindowsCredential    
    }
    catch { $errVariables += $_ }

    if( [String]::IsNullOrEmpty($ssn) ) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Attemping PSSession for [$ssnHostName] using provided WindowsCredentials with Negotiate attribute.."
        $ssn = New-PSSession -ComputerName $ssnHostName -Credential $WindowsCredential -Authentication Negotiate
    }
}

if ( [String]::IsNullOrEmpty($ssn) ) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Provide WindowsCredential for accessing server [$ssnHostName] of domain '$($sqlServerInfo.domain)'." | Write-Host -ForegroundColor Red
    "STOP here, and fix above issue." | Write-Error -ForegroundColor Red
}


# Validate database collation
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Validating Collation of databases.."
$sqlDbCollation = @"
select name as [db_name], collation_name from sys.databases 
where collation_name not in ('SQL_Latin1_General_CP1_CI_AS') 
and name in ('master','msdb','tempdb','$DbaDatabase')
"@
$dbCollationResult = @()
$dbCollationResult += Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Query $sqlDbCollation -EnableException -SqlCredential $SqlCredential
if($dbCollationResult.Count -ne 0) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Collation of below databases is not [SQL_Latin1_General_CP1_CI_AS]." | Write-Host -ForegroundColor Red
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Kindly rectify this collation problem." | Write-Host -ForegroundColor Red
    $dbCollationResult | Format-Table -AutoSize | Write-Host -ForegroundColor Red
    Write-Error "Stop here. Fix above issue."
}


# Validate mail profile
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Checking for default global mail profile.."
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$MailProfileFilePath = '$MailProfileFilePath'"
$sqlMailProfile = @"
SELECT p.name as profile_name, p.description as profile_description, a.name as mail_account, 
		a.email_address, a.display_name, a.replyto_address, s.servername, s.port, s.servername,
		pp.is_default
FROM msdb.dbo.sysmail_profile p 
JOIN msdb.dbo.sysmail_principalprofile pp ON pp.profile_id = p.profile_id AND pp.is_default = 1
JOIN msdb.dbo.sysmail_profileaccount pa ON p.profile_id = pa.profile_id 
JOIN msdb.dbo.sysmail_account a ON pa.account_id = a.account_id 
JOIN msdb.dbo.sysmail_server s ON a.account_id = s.account_id
WHERE pp.is_default = 1
"@
$mailProfile = @()
$mailProfile += Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database msdb -Query $sqlMailProfile -EnableException -SqlCredential $SqlCredential
if($mailProfile.Count -lt 1) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Kindly create default global mail profile." | Write-Host -ForegroundColor Red
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Kindly utilize '$mailProfileFilePath." | Write-Host -ForegroundColor Red
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Opening the file '$mailProfileFilePath' in notepad.." | Write-Host -ForegroundColor Red
    notepad "$mailProfileFilePath"

    $mailProfile += Get-DbaDbMailProfile -SqlInstance $SqlInstanceToBaseline -SqlCredential $SqlCredential
    if($mailProfile.Count -ne 0) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Below mail profile(s) exists.`nOne of them can be set to default global profile." | Write-Host -ForegroundColor Red
        $mailProfile | Format-Table -AutoSize
    }

    Write-Error "Stop here. Fix above issue."
}


# 1__sp_WhoIsActive
$stepName = '1__sp_WhoIsActive'
if($stepName -in $Steps2Execute) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$WhoIsActiveFilePath = '$WhoIsActiveFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating sp_WhoIsActive in [master] database.."
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -File $WhoIsActiveFilePath -SqlCredential $SqlCredential -EnableException
}


# 2__AllDatabaseObjects
$stepName = '2__AllDatabaseObjects'
if($stepName -in $Steps2Execute) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating All Objects in [$DbaDatabase] database.."
    if($IsNonPartitioned) {
        $AllDatabaseObjectsFileName = "$($AllDatabaseObjectsFileName -replace '.sql','')-NonSupportedVersions.sql"
        $AllDatabaseObjectsFilePath = Join-Path $ddlPath $AllDatabaseObjectsFileName
    }
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$AllDatabaseObjectsFilePath = '$AllDatabaseObjectsFilePath'"
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -File $AllDatabaseObjectsFilePath -SqlCredential $SqlCredential -EnableException

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Adding entry into [dbo].[instance_hosts].."
    $sqlAddInstanceHost = @"
        if not exists (select * from dbo.instance_hosts where host_name = '$HostName')
        begin
	        insert dbo.instance_hosts ([host_name])
	        select [host_name] = '$HostName';
            
            select * from dbo.instance_hosts
        end
"@
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -Query $sqlAddInstanceHost -SqlCredential $SqlCredential -EnableException | ft -AutoSize

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Adding entry into [dbo].[instance_details].."
    $sqlAddInstanceHostMapping = @"
    if not exists (select * from dbo.instance_details where sql_instance = '$SqlInstanceToBaseline' and [host_name] = '$HostName')
    begin
	    insert dbo.instance_details ( [sql_instance], [host_name], [collector_sql_instance] )
	    select	[sql_instance] = '$SqlInstanceToBaseline',
			    [host_name] = '$Hostname',
			    [collector_sql_instance] = '$SqlInstanceForDataCollectionJobs';

        select * from dbo.instance_details
    end
"@
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -Query $sqlAddInstanceHostMapping -SqlCredential $SqlCredential -EnableException | ft -AutoSize
}


# 3__XEventSession
$stepName = '3__XEventSession'
if($stepName -in $Steps2Execute) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$XEventSessionFilePath = '$XEventSessionFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Fetch [$DbaDatabase] path.."

    $sqlDbaDatabasePath = @"
    select top 1 physical_name FROM sys.master_files 
    where database_id = DB_ID('$DbaDatabase') and type_desc = 'ROWS' 
    and physical_name not like 'C:\%' order by file_id;
"@
    $dbaDatabasePath = Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database master -SqlCredential $SqlCredential -Query $sqlDbaDatabasePath -EnableException | Select-Object -ExpandProperty physical_name
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$dbaDatabasePath => '$dbaDatabasePath'.."

    $xEventTargetPathParentDirectory = (Split-Path (Split-Path $dbaDatabasePath -Parent))
    if($xEventTargetPathParentDirectory.Length -eq 3) {
        $xEventTargetPathDirectory = "${xEventTargetPathParentDirectory}xevents"
    } else {
        $xEventTargetPathDirectory = Join-Path -Path $xEventTargetPathParentDirectory -ChildPath "xevents"
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Computed XEvent files directory -> '$xEventTargetPathDirectory'.."
    if(-not (Test-Path $($xEventTargetPathDirectory))) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Create directory '$xEventTargetPathDirectory' for XEvent files.."
        Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -SqlCredential $SqlCredential -Query "EXEC xp_create_subdir '$xEventTargetPathDirectory'" -EnableException
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Create XEvent session named [resource_consumption].."
    $sqlXEventSession = [System.IO.File]::ReadAllText($XEventSessionFilePath).Replace('E:\Data\xevents', "$xEventTargetPathDirectory")
    try {
        Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database master -Query $sqlXEventSession -SqlCredential $SqlCredential -EnableException | Format-Table -AutoSize
    }
    catch {
        $errMessage = $_
        $errMessage | gm
        if($errMessage.Exception.Message -like "The value specified for event attribute or predicate source*") {
            $sqlXEventSession = $sqlXEventSession.Replace("WHERE ( ([duration]>=5000000) OR ([result]<>('OK')) ))", "WHERE ( ([duration]>=5000000) ))")
        }
        Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database master -Query $sqlXEventSession -SqlCredential $SqlCredential -EnableException | Format-Table -AutoSize
    }
}


# 4__FirstResponderKitObjects
$stepName = '4__FirstResponderKitObjects'
if($stepName -in $Steps2Execute) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating FirstResponderKit Objects in [master] database.."
    Install-DbaFirstResponderKit -SqlInstance $SqlInstanceToBaseline -Database master -EnableException -SqlCredential $SqlCredential -Verbose:$false -Debug:$false | Format-Table -AutoSize
}


# 5__DarlingDataObjects
$stepName = '5__DarlingDataObjects'
if($stepName -in $Steps2Execute) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating DarlingData Objects in [master] database.."
    Install-DbaDarlingData -SqlInstance $SqlInstanceToBaseline -Database master -SqlCredential $SqlCredential -EnableException | Format-Table -AutoSize
}


# 6__OlaHallengrenSolutionObjects
$stepName = '6__OlaHallengrenSolutionObjects'
if($stepName -in $Steps2Execute) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating OlaHallengren Solution Objects in [$DbaDatabase] database.."
    Install-DbaMaintenanceSolution -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -SqlCredential $SqlCredential -EnableException -ReplaceExisting | Format-Table -AutoSize
}


# 7__sp_WhatIsRunning
$stepName = '7__sp_WhatIsRunning'
if($stepName -in $Steps2Execute) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$WhatIsRunningFilePath = '$WhatIsRunningFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating sp_WhatIsRunning procedure in [$DbaDatabase] database.."
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -File $WhatIsRunningFilePath -SqlCredential $SqlCredential -EnableException | Format-Table -AutoSize
}


# 8__usp_GetAllServerInfo
$stepName = '8__usp_GetAllServerInfo'
if($stepName -in $Steps2Execute -and $SqlInstanceToBaseline -eq $InventoryServer) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$GetAllServerInfoFilePath = '$GetAllServerInfoFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating usp_GetAllServerInfo procedure in [$DbaDatabase] database.."
    if([String]::IsNullOrEmpty($SqlCredential)) {
        Invoke-Sqlcmd -ServerInstance $InventoryServer -Database $DbaDatabase -InputFile $GetAllServerInfoFilePath
    }
    else {
        Invoke-Sqlcmd -ServerInstance $InventoryServer -Database $DbaDatabase -InputFile $GetAllServerInfoFilePath -Credential $SqlCredential
    }
    #Invoke-DbaQuery -SqlInstance $InventoryServer -Database $DbaDatabase -File $GetAllServerInfoFilePath -EnableException
}


# 9__CopyDbaToolsModule2Host
$stepName = '9__CopyDbaToolsModule2Host'
if($stepName -in $Steps2Execute) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$DbaToolsFolderPath = '$DbaToolsFolderPath'"
    
    $remoteModulePath = Invoke-Command -Session $ssn -ScriptBlock {
        $modulePath = $null
        if('C:\Program Files\WindowsPowerShell\Modules' -in $($env:PSModulePath -split ';')) {
            $modulePath = 'C:\Program Files\WindowsPowerShell\Modules'
        }
        else {
            $modulePath = $($env:PSModulePath -split ';') | Where-Object {$_ -like '*Microsoft SQL Server*'} | select -First 1
        }
        $modulePath
    }

    $dbatoolsRemotePath = Join-Path $remoteModulePath 'dbatools'
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Copy dbatools module from '$DbaToolsFolderPath' to host [$HostName] on '$dbatoolsRemotePath'.."
    
    if( (Invoke-Command -Session $ssn -ScriptBlock {Test-Path $Using:dbatoolsRemotePath}) ) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "'$dbatoolsRemotePath' already exists on host [$HostName]."
    }
    else {
        Copy-Item $DbaToolsFolderPath -Destination $dbatoolsRemotePath -ToSession $ssn -Recurse
    }
}


# 10__CopyPerfmonFolder2Host
$stepName = '10__CopyPerfmonFolder2Host'
if($stepName -in $Steps2Execute) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$psScriptPath = '$psScriptPath'"
    
    if( (Invoke-Command -Session $ssn -ScriptBlock {Test-Path $Using:RemoteSQLMonitorPath}) ) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "'$RemoteSQLMonitorPath' already exists on host [$HostName]."
    }
    else {
        Copy-Item $psScriptPath -Destination $RemoteSQLMonitorPath -ToSession $ssn -Recurse
    }
}


# 11__SetupPerfmonDataCollector
$stepName = '11__SetupPerfmonDataCollector'
if($stepName -in $Steps2Execute) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Setup Data Collector set 'DBA' on host '$HostName'.."
    Invoke-Command -Session $ssn -ScriptBlock {
        # Set execution policy
        Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy Unrestricted -Force 
        & "$Using:RemoteSQLMonitorPath\perfmon-collector-logman.ps1" -TemplatePath "$Using:RemoteSQLMonitorPath\DBA_PerfMon_All_Counters_Template.xml"
    }
}


# 12__CreateCredentialProxy. Create Credential & Proxy on SQL Server. If Instance being baselined is same as data collector job owner
$stepName = '12__CreateCredentialProxy'
if( $SqlInstanceForDataCollectionJobs -eq $SqlInstanceToBaseline -and $requireProxy) {
    $credentialName = $WindowsCredential.UserName
    $credentialPassword = $WindowsCredential.Password

    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Create new SQL Credential [$credentialName] on [$SqlInstanceToBaseline].."
    $dbaCredential = @()
    $dbaCredential += Get-DbaCredential -SqlInstance $SqlInstanceToBaseline -Name $credentialName -SqlCredential $SqlCredential -EnableException
    if($dbaCredential.Count -eq 0) {
        New-DbaCredential -SqlInstance $SqlInstanceToBaseline -Identity $credentialName -SecurePassword $credentialPassword -SqlCredential $SqlCredential -EnableException
    } else {
        "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "SQL Credential [$credentialName] already exists on [$SqlInstanceToBaseline].."
    }
    $dbaAgentProxy = @()
    $dbaAgentProxy += Get-DbaAgentProxy -SqlInstance $SqlInstanceToBaseline -Proxy $credentialName -SqlCredential $SqlCredential -EnableException
    if($dbaAgentProxy.Count -eq 0) {
        New-DbaAgentProxy -SqlInstance $SqlInstanceToBaseline -Name $credentialName -ProxyCredential $credentialName -SubSystem CmdExec, PowerShell -SqlCredential $SqlCredential -EnableException
    } else {
        "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "SQL Agent Proxy [$credentialName] already exists on [$SqlInstanceToBaseline].."
    }
}


# 12__CreateJobCollectOSProcesses
$stepName = '12__CreateJobCollectOSProcesses'
if($stepName -in $Steps2Execute) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$CollectOSProcessesFilePath = '$CollectOSProcessesFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [(dba) Collect-OSProcesses] on [$SqlInstanceForDataCollectionJobs].."
    $sqlCreateJobCollectOSProcesses = [System.IO.File]::ReadAllText($CollectOSProcessesFilePath).Replace('-SqlInstance localhost', "-SqlInstance `"$SqlInstanceAsDataDestination`"")
    $sqlCreateJobCollectOSProcesses = $sqlCreateJobCollectOSProcesses.Replace('-Database DBA', "-Database `"$DbaDatabase`"")
    $sqlCreateJobCollectOSProcesses = $sqlCreateJobCollectOSProcesses.Replace('-HostName localhost', "-HostName `"$HostName`"")
    if($RemoteSQLMonitorPath -ne 'C:\SQLMonitor') {
        $sqlCreateJobCollectOSProcesses = $sqlCreateJobCollectOSProcesses.Replace('C:\SQLMonitor', $RemoteSQLMonitorPath)
    }
    if($DropCreatePowerShellJobs) {
        $tsqlSSMSValidation = "and APP_NAME() = 'Microsoft SQL Server Management Studio - Query'"
        $sqlCreateJobCollectOSProcesses = $sqlCreateJobCollectOSProcesses.Replace($tsqlSSMSValidation, "--$tsqlSSMSValidation")
    }
    Invoke-DbaQuery -SqlInstance $SqlInstanceForDataCollectionJobs -Database msdb -Query $sqlCreateJobCollectOSProcesses -SqlCredential $SqlCredential -EnableException

    if($requireProxy) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Update job [(dba) Collect-OSProcesses] to run under proxy [$credentialName].."
        $sqlUpdateJob = "EXEC msdb.dbo.sp_update_jobstep @job_name=N'(dba) Collect-OSProcesses', @step_id=1 ,@proxy_name=N'$credentialName';"
        Invoke-DbaQuery -SqlInstance $SqlInstanceForDataCollectionJobs -Database msdb -Query $sqlUpdateJob -SqlCredential $SqlCredential -EnableException
    }
    $sqlStartJob = "EXEC msdb.dbo.sp_start_job @job_name=N'(dba) Collect-OSProcesses';"
    Invoke-DbaQuery -SqlInstance $SqlInstanceForDataCollectionJobs -Database msdb -Query $sqlStartJob -SqlCredential $SqlCredential -EnableException
}


# 13__CreateJobCollectPerfmonData
$stepName = '13__CreateJobCollectPerfmonData'
if($stepName -in $Steps2Execute) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$CollectPerfmonDataFilePath = '$CollectPerfmonDataFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [(dba) Collect-PerfmonData] on [$SqlInstanceForDataCollectionJobs].."
    $sqlCreateJobCollectPerfmonData = [System.IO.File]::ReadAllText($CollectPerfmonDataFilePath).Replace('-SqlInstance localhost', "-SqlInstance `"$SqlInstanceAsDataDestination`"")
    $sqlCreateJobCollectPerfmonData = $sqlCreateJobCollectPerfmonData.Replace('-Database DBA', "-Database `"$DbaDatabase`"")
    $sqlCreateJobCollectPerfmonData = $sqlCreateJobCollectPerfmonData.Replace('-HostName localhost', "-HostName `"$HostName`"")
    
    if($RemoteSQLMonitorPath -ne 'C:\SQLMonitor') {
        $sqlCreateJobCollectPerfmonData = $sqlCreateJobCollectPerfmonData.Replace('C:\SQLMonitor', $RemoteSQLMonitorPath)
    }
    if($DropCreatePowerShellJobs) {
        $tsqlSSMSValidation = "and APP_NAME() = 'Microsoft SQL Server Management Studio - Query'"
        $sqlCreateJobCollectPerfmonData = $sqlCreateJobCollectPerfmonData.Replace($tsqlSSMSValidation, "--$tsqlSSMSValidation")
    }
    Invoke-DbaQuery -SqlInstance $SqlInstanceForDataCollectionJobs -Database msdb -Query $sqlCreateJobCollectPerfmonData -SqlCredential $SqlCredential -EnableException

    if($requireProxy) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Update job [(dba) Collect-PerfmonData] to run under proxy [$credentialName].."
        $sqlUpdateJob = "EXEC msdb.dbo.sp_update_jobstep @job_name=N'(dba) Collect-PerfmonData', @step_id=1 ,@proxy_name=N'$credentialName';"
        Invoke-DbaQuery -SqlInstance $SqlInstanceForDataCollectionJobs -Database msdb -Query $sqlUpdateJob -SqlCredential $SqlCredential -EnableException
    }
    $sqlStartJob = "EXEC msdb.dbo.sp_start_job @job_name=N'(dba) Collect-PerfmonData';"
    Invoke-DbaQuery -SqlInstance $SqlInstanceForDataCollectionJobs -Database msdb -Query $sqlStartJob -SqlCredential $SqlCredential -EnableException
}


# 14__CreateJobCollectWaitStats
$stepName = '14__CreateJobCollectWaitStats'
if($stepName -in $Steps2Execute) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$CollectWaitStatsFilePath = '$CollectWaitStatsFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [(dba) Collect-WaitStats] on [$SqlInstanceToBaseline].."
    $sqlCreateJobCollectWaitStats = [System.IO.File]::ReadAllText($CollectWaitStatsFilePath).Replace("@database_name=N'DBA'", "@database_name=N'$DbaDatabase'")
    $sqlCreateJobCollectWaitStats = $sqlCreateJobCollectWaitStats.Replace("varchar(500) = ''some_dba_mail_id@gmail.com'';", "varchar(500) = ''$($DbaGroupMailId -join ';')'';"   )
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database msdb -Query $sqlCreateJobCollectWaitStats -SqlCredential $SqlCredential -EnableException
}


# 15__CreateJobCollectXEvents
$stepName = '15__CreateJobCollectXEvents'
if($stepName -in $Steps2Execute) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$CollectXEventsFilePath = '$CollectXEventsFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [(dba) Collect-XEvents] on [$SqlInstanceToBaseline].."
    $sqlCreateJobCollectXEvents = [System.IO.File]::ReadAllText($CollectXEventsFilePath).Replace("@database_name=N'DBA'", "@database_name=N'$DbaDatabase'")
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database msdb -Query $sqlCreateJobCollectXEvents -SqlCredential $SqlCredential -EnableException
}


# 16__CreateJobPartitionsMaintenance
$stepName = '16__CreateJobPartitionsMaintenance'
if($stepName -in $Steps2Execute -and $IsNonPartitioned -eq $false) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$PartitionsMaintenanceFilePath = '$PartitionsMaintenanceFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [(dba) Partitions-Maintenance] on [$SqlInstanceToBaseline].."
    $sqlPartitionsMaintenance = [System.IO.File]::ReadAllText($PartitionsMaintenanceFilePath).Replace("@database_name=N'DBA'", "@database_name=N'$DbaDatabase'")
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database msdb -Query $sqlPartitionsMaintenance -SqlCredential $SqlCredential -EnableException
}


# 17__CreateJobPurgeTables
$stepName = '17__CreateJobPurgeTables'
if($stepName -in $Steps2Execute) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$PurgeTablesFilePath = '$PurgeTablesFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [(dba) Purge-DbaMetrics - Daily] on [$SqlInstanceToBaseline].."
    $sqlPurgeDbaMetrics = [System.IO.File]::ReadAllText($PurgeTablesFilePath).Replace("@database_name=N'DBA'", "@database_name=N'$DbaDatabase'")
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database msdb -Query $sqlPurgeDbaMetrics -SqlCredential $SqlCredential -EnableException
}


# 18__CreateJobRemoveXEventFiles
$stepName = '18__CreateJobRemoveXEventFiles'
if($stepName -in $Steps2Execute) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$RemoveXEventFilesFilePath = '$RemoveXEventFilesFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [(dba) Remove-XEventFiles] on [$SqlInstanceToBaseline].."
    $sqlCreateJobRemoveXEventFiles = [System.IO.File]::ReadAllText($RemoveXEventFilesFilePath).Replace('-SqlInstance localhost', "-SqlInstance `"$SqlInstanceToBaseline`"")
    $sqlCreateJobRemoveXEventFiles = $sqlCreateJobRemoveXEventFiles.Replace('-Database DBA', "-Database `"$DbaDatabase`"")

    if($RemoteSQLMonitorPath -ne 'C:\SQLMonitor') {
        $sqlCreateJobRemoveXEventFiles = $sqlCreateJobRemoveXEventFiles.Replace('C:\SQLMonitor', $RemoteSQLMonitorPath)
    }
    if($DropCreatePowerShellJobs) {
        $tsqlSSMSValidation = "and APP_NAME() = 'Microsoft SQL Server Management Studio - Query'"
        $sqlCreateJobRemoveXEventFiles = $sqlCreateJobRemoveXEventFiles.Replace($tsqlSSMSValidation, "--$tsqlSSMSValidation")
    }
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database msdb -Query $sqlCreateJobRemoveXEventFiles -SqlCredential $SqlCredential -EnableException

    if($requireProxy) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Update job [(dba) Remove-XEventFiles] to run under proxy [$credentialName].."
        $sqlUpdateJob = "EXEC msdb.dbo.sp_update_jobstep @job_name=N'(dba) Remove-XEventFiles', @step_id=1 ,@proxy_name=N'$credentialName';"
        Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database msdb -Query $sqlUpdateJob -SqlCredential $SqlCredential -EnableException
    }
    $sqlStartJob = "EXEC msdb.dbo.sp_start_job @job_name=N'(dba) Remove-XEventFiles';"
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database msdb -Query $sqlStartJob -SqlCredential $SqlCredential -EnableException
}


# 19__CreateJobRunWhoIsActive
$stepName = '19__CreateJobRunWhoIsActive'
if($stepName -in $Steps2Execute) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$RunWhoIsActiveFilePath = '$RunWhoIsActiveFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [(dba) Run-WhoIsActive] on [$SqlInstanceToBaseline].."
    $sqlRunWhoIsActive = [System.IO.File]::ReadAllText($RunWhoIsActiveFilePath).Replace("@database_name=N'DBA'", "@database_name=N'$DbaDatabase'")
    $sqlRunWhoIsActive = $sqlRunWhoIsActive.Replace("varchar(500) = ''some_dba_mail_id@gmail.com'';", "varchar(500) = ''$($DbaGroupMailId -join ';')'';"   )
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database msdb -Query $sqlRunWhoIsActive -SqlCredential $SqlCredential -EnableException
}


# 20__CreateJobUpdateSqlServerVersions
$stepName = '20__CreateJobUpdateSqlServerVersions'
if($stepName -in $Steps2Execute -and $SqlInstanceToBaseline -eq $InventoryServer) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$UpdateSqlServerVersionsFilePath = '$UpdateSqlServerVersionsFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [(dba) Update-SqlServerVersions] on [$SqlInstanceToBaseline].."
    $sqlUpdateSqlServerVersions = [System.IO.File]::ReadAllText($UpdateSqlServerVersionsFilePath).Replace('-SqlInstance localhost', "-SqlInstance `"$SqlInstanceToBaseline`"")

    if($RemoteSQLMonitorPath -ne 'C:\SQLMonitor') {
        $sqlUpdateSqlServerVersions = $sqlUpdateSqlServerVersions.Replace('C:\SQLMonitor', $RemoteSQLMonitorPath)
    }
    if($DropCreatePowerShellJobs) {
        $tsqlSSMSValidation = "and APP_NAME() = 'Microsoft SQL Server Management Studio - Query'"
        $sqlUpdateSqlServerVersions = $sqlUpdateSqlServerVersions.Replace($tsqlSSMSValidation, "--$tsqlSSMSValidation")
    }
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database msdb -Query $sqlUpdateSqlServerVersions -SqlCredential $SqlCredential -EnableException

    if($requireProxy) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Update job [(dba) Update-SqlServerVersions] to run under proxy [$credentialName].."
        $sqlUpdateJob = @"
        EXEC msdb.dbo.sp_update_jobstep @job_name=N'(dba) Update-SqlServerVersions', @step_id=1 ,@proxy_name=N'$credentialName';
        GO
        EXEC msdb.dbo.sp_start_job @job_name=N'(dba) Update-SqlServerVersions';
        GO
"@
        Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database msdb -Query $sqlUpdateJob -SqlCredential $SqlCredential -EnableException
    }
}


# 21__WhoIsActivePartition
$stepName = '21__WhoIsActivePartition'
if($stepName -in $Steps2Execute -and $IsNonPartitioned -eq $false) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$WhoIsActivePartitionFilePath = '$WhoIsActivePartitionFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "ALTER [dbo].[WhoIsActive] table to partitioned table on [$SqlInstanceToBaseline].."
    $sqlPartitionWhoIsActive = [System.IO.File]::ReadAllText($WhoIsActivePartitionFilePath).Replace("[DBA]", "[$DbaDatabase]")
    
    $whoIsActiveExists = @()
    $loopStartTime = Get-Date
    $sleepDurationSeconds = 30
    $loopTotalDurationThresholdSeconds = 300    
    
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Check for existance of table [dbo].[WhoIsActive] on [$SqlInstanceToBaseline].."
    while ($whoIsActiveExists.Count -eq 0 -and $( (New-TimeSpan $loopStartTime $(Get-Date)).TotalSeconds -le $loopTotalDurationThresholdSeconds ) )
    {
        $whoIsActiveExists += Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -SqlCredential $SqlCredential `
                                    -Query "if OBJECT_ID('dbo.WhoIsActive') is not null select OBJECT_ID('dbo.WhoIsActive') as WhoIsActiveObjectID" -EnableException

        if($whoIsActiveExists.Count -eq 0) {
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Wait for $sleepDurationSeconds seconds as table dbo.WhoIsActive still does not exist.."
            Start-Sleep -Seconds $sleepDurationSeconds
        }
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Seems table exists now. Convert [dbo].[WhoIsActive] into partitioned table.."
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -Query $sqlPartitionWhoIsActive -SqlCredential $SqlCredential -EnableException
}


# 22__GrafanaLogin
$stepName = '22__GrafanaLogin'
if($stepName -in $Steps2Execute) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$GrafanaLoginFilePath = '$GrafanaLoginFilePath'"
    #"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating All Objects in [$DbaDatabase] database.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Create [grafana] login & user with permissions on objects.."
    $sqlGrafanaLogin = [System.IO.File]::ReadAllText($GrafanaLoginFilePath).Replace("[DBA]", "[$DbaDatabase]")
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database master -Query $sqlGrafanaLogin -SqlCredential $SqlCredential -EnableException
}


# 23__LinkedServerOnInventory
$stepName = '23__LinkedServerOnInventory'
if($stepName -in $Steps2Execute -and $SqlInstanceToBaseline -ne $InventoryServer) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$LinkedServerOnInventoryFilePath = '$LinkedServerOnInventoryFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating linked server for [$SqlInstanceToBaseline] on [$InventoryServer].."
    $sqlLinkedServerOnInventory = [System.IO.File]::ReadAllText($LinkedServerOnInventoryFilePath).Replace("'YourSqlInstanceNameHere'", "'$SqlInstanceToBaseline'")
    $sqlLinkedServerOnInventory = $sqlLinkedServerOnInventory.Replace("@catalog=N'DBA'", "@catalog=N'$DbaDatabase'")
    
    $dbaLinkedServer = @()
    $dbaLinkedServer += Get-DbaLinkedServer -SqlInstance $InventoryServer -LinkedServer $SqlInstanceToBaseline
    if($dbaLinkedServer.Count -eq 0) {
        Invoke-DbaQuery -SqlInstance $InventoryServer -Database master -Query $sqlLinkedServerOnInventory -SqlCredential $SqlCredential -EnableException
    } else {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Linked server for [$SqlInstanceToBaseline] on [$InventoryServer] already exists.."
    }
}



"`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Baselining of [$SqlInstanceToBaseline] completed."

$timeTaken = New-TimeSpan -Start $startTime -End $(Get-Date)
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Execution completed in $($timeTaken.TotalSeconds) seconds."

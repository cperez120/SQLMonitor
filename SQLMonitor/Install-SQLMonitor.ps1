﻿[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)]
    [String]$SqlInstanceToBaseline,

    [Parameter(Mandatory=$false)]
    [String]$DbaDatabase = 'DBA',

    [Parameter(Mandatory=$false)]
    [String]$SqlInstanceAsDataDestination,

    [Parameter(Mandatory=$false)]
    [String]$SqlInstanceForTsqlJobs,

    [Parameter(Mandatory=$false)]
    [String]$SqlInstanceForPowershellJobs,

    [Parameter(Mandatory=$true)]
    [String]$InventoryServer,

    [Parameter(Mandatory=$false)]
    [String]$InventoryDatabase = 'DBA',

    [Parameter(Mandatory=$false)]
    [String]$HostName,

    [Parameter(Mandatory=$false)]
    [String]$SQLMonitorPath,

    [Parameter(Mandatory=$true)]
    [String]$DbaToolsFolderPath,

    [Parameter(Mandatory=$false)]
    [String]$FirstResponderKitZipFile,

    [Parameter(Mandatory=$false)]
    [String]$DarlingDataZipFile,

    [Parameter(Mandatory=$false)]
    [String]$RemoteSQLMonitorPath = 'C:\SQLMonitor',

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
    [String]$UspGetAllServerInfoFileName = "SCH-usp_GetAllServerInfo.sql",

    [Parameter(Mandatory=$false)]
    [String]$UspCollectWaitStatsFileName = "SCH-usp_collect_wait_stats.sql",

    [Parameter(Mandatory=$false)]
    [String]$UspCollectFileIOStatsFileName = "SCH-usp_collect_file_io_stats.sql",

    [Parameter(Mandatory=$false)]
    [String]$UspCollectXeventsResourceConsumptionFileName = "SCH-usp_collect_xevents_resource_consumption.sql",

    [Parameter(Mandatory=$false)]
    [String]$UspPartitionMaintenanceFileName = "SCH-usp_partition_maintenance.sql",

    [Parameter(Mandatory=$false)]
    [String]$UspPurgeTablesFileName = "SCH-usp_purge_tables.sql",

    [Parameter(Mandatory=$false)]
    [String]$UspRunWhoIsActiveFileName = "SCH-usp_run_WhoIsActive.sql",

    [Parameter(Mandatory=$false)]
    [String]$UspActiveRequestsCountFileName = "SCH-usp_active_requests_count.sql",

    [Parameter(Mandatory=$false)]
    [String]$UspWaitsPerCorePerMinuteFileName = "SCH-usp_waits_per_core_per_minute.sql",

    [Parameter(Mandatory=$false)]
    [String]$UspEnablePageCompressionFileName = "SCH-usp_enable_page_compression.sql",

    [Parameter(Mandatory=$false)]
    [String]$WhoIsActivePartitionFileName = "SCH-WhoIsActive-Partitioning.sql",

    [Parameter(Mandatory=$false)]
    [String]$BlitzIndexPartitionFileName = "SCH-BlitzIndex-Partitioning.sql",

    [Parameter(Mandatory=$false)]
    [String]$GrafanaLoginFileName = "grafana-login.sql",

    [Parameter(Mandatory=$false)]
    [String]$CheckInstanceAvailabilityJobFileName = "SCH-Job-[(dba) Check-InstanceAvailability].sql",

    [Parameter(Mandatory=$false)]
    [String]$CollectDiskSpaceJobFileName = "SCH-Job-[(dba) Collect-DiskSpace].sql",

    [Parameter(Mandatory=$false)]
    [String]$CollectOSProcessesJobFileName = "SCH-Job-[(dba) Collect-OSProcesses].sql",

    [Parameter(Mandatory=$false)]
    [String]$CollectPerfmonDataJobFileName = "SCH-Job-[(dba) Collect-PerfmonData].sql",

    [Parameter(Mandatory=$false)]
    [String]$CollectWaitStatsJobFileName = "SCH-Job-[(dba) Collect-WaitStats].sql",

    [Parameter(Mandatory=$false)]
    [String]$CollectFileIOStatsJobFileName = "SCH-Job-[(dba) Collect-FileIOStats].sql",

    [Parameter(Mandatory=$false)]
    [String]$CollectXEventsJobFileName = "SCH-Job-[(dba) Collect-XEvents].sql",

    [Parameter(Mandatory=$false)]
    [String]$PartitionsMaintenanceJobFileName = "SCH-Job-[(dba) Partitions-Maintenance].sql",

    [Parameter(Mandatory=$false)]
    [String]$PurgeTablesJobFileName = "SCH-Job-[(dba) Purge-Tables].sql",

    [Parameter(Mandatory=$false)]
    [String]$RemoveXEventFilesJobFileName = "SCH-Job-[(dba) Remove-XEventFiles].sql",

    [Parameter(Mandatory=$false)]
    [String]$RunWhoIsActiveJobFileName = "SCH-Job-[(dba) Run-WhoIsActive].sql",

    [Parameter(Mandatory=$false)]
    [String]$UpdateSqlServerVersionsJobFileName = "SCH-Job-[(dba) Update-SqlServerVersions].sql",

    [Parameter(Mandatory=$false)]
    [String]$GetAllServerInfoJobFileName = "SCH-Job-[(dba) Get-AllServerInfo].sql",

    [Parameter(Mandatory=$false)]
    [String]$InventorySpecificObjectsFileName = "SCH-Create-Inventory-Specific-Objects.sql",

    [Parameter(Mandatory=$false)]
    [String]$LinkedServerOnInventoryFileName = "SCH-Linked-Servers-Sample.sql",

    [Parameter(Mandatory=$false)]
    [String]$TestWindowsAdminAccessJobFileName = "SCH-Job-[(dba) Test-WindowsAdminAccess].sql",

    [Parameter(Mandatory=$false)]
    [String]$RunBlitzIndexJobFileName = "SCH-Job-[(dba) Run-BlitzIndex].sql",

    [Parameter(Mandatory=$false)]
    [String]$RunBlitzIndexWeeklyJobFileName = "SCH-Job-[(dba) Run-BlitzIndex - Weekly].sql",

    [Parameter(Mandatory=$false)]
    [String[]]$DbaGroupMailId,

    [Parameter(Mandatory=$false)]
    [ValidateSet("1__sp_WhoIsActive", "2__AllDatabaseObjects", "3__XEventSession",
                "4__FirstResponderKitObjects", "5__DarlingDataObjects", "6__sp_WhatIsRunning",
                "7__usp_GetAllServerInfo", "8__CopyDbaToolsModule2Host", "9__CopyPerfmonFolder2Host",
                "10__SetupPerfmonDataCollector", "11__CreateCredentialProxy", "12__CreateJobCollectDiskSpace",
                "13__CreateJobCollectOSProcesses", "14__CreateJobCollectPerfmonData", "15__CreateJobCollectWaitStats",
                "16__CreateJobCollectXEvents", "17__CreateJobCollectFileIOStats", "18__CreateJobPartitionsMaintenance",
                "19__CreateJobPurgeTables", "20__CreateJobRemoveXEventFiles", "21__CreateJobRunWhoIsActive",
                "22__CreateJobRunBlitzIndex", "23__CreateJobRunBlitzIndexWeekly", "24__CreateJobUpdateSqlServerVersions",
                "25__CreateJobCheckInstanceAvailability", "26__CreateJobGetAllServerInfo", "27__WhoIsActivePartition",
                "28__BlitzIndexPartition", "29__EnablePageCompression", "30__GrafanaLogin",
                "31__LinkedServerOnInventory", "32__LinkedServerForDataDestinationInstance", "33__AlterViewsForDataDestinationInstance")]
    [String]$StartAtStep = "1__sp_WhoIsActive",

    [Parameter(Mandatory=$false)]
    [ValidateSet("1__sp_WhoIsActive", "2__AllDatabaseObjects", "3__XEventSession",
                "4__FirstResponderKitObjects", "5__DarlingDataObjects", "6__sp_WhatIsRunning",
                "7__usp_GetAllServerInfo", "8__CopyDbaToolsModule2Host", "9__CopyPerfmonFolder2Host",
                "10__SetupPerfmonDataCollector", "11__CreateCredentialProxy", "12__CreateJobCollectDiskSpace",
                "13__CreateJobCollectOSProcesses", "14__CreateJobCollectPerfmonData", "15__CreateJobCollectWaitStats",
                "16__CreateJobCollectXEvents", "17__CreateJobCollectFileIOStats", "18__CreateJobPartitionsMaintenance",
                "19__CreateJobPurgeTables", "20__CreateJobRemoveXEventFiles", "21__CreateJobRunWhoIsActive",
                "22__CreateJobRunBlitzIndex", "23__CreateJobRunBlitzIndexWeekly", "24__CreateJobUpdateSqlServerVersions",
                "25__CreateJobCheckInstanceAvailability", "26__CreateJobGetAllServerInfo", "27__WhoIsActivePartition",
                "28__BlitzIndexPartition", "29__EnablePageCompression", "30__GrafanaLogin",
                "31__LinkedServerOnInventory", "32__LinkedServerForDataDestinationInstance", "33__AlterViewsForDataDestinationInstance")]
    [String[]]$SkipSteps,

    [Parameter(Mandatory=$false)]
    [ValidateSet("1__sp_WhoIsActive", "2__AllDatabaseObjects", "3__XEventSession",
                "4__FirstResponderKitObjects", "5__DarlingDataObjects", "6__sp_WhatIsRunning",
                "7__usp_GetAllServerInfo", "8__CopyDbaToolsModule2Host", "9__CopyPerfmonFolder2Host",
                "10__SetupPerfmonDataCollector", "11__CreateCredentialProxy", "12__CreateJobCollectDiskSpace",
                "13__CreateJobCollectOSProcesses", "14__CreateJobCollectPerfmonData", "15__CreateJobCollectWaitStats",
                "16__CreateJobCollectXEvents", "17__CreateJobCollectFileIOStats", "18__CreateJobPartitionsMaintenance",
                "19__CreateJobPurgeTables", "20__CreateJobRemoveXEventFiles", "21__CreateJobRunWhoIsActive",
                "22__CreateJobRunBlitzIndex", "23__CreateJobRunBlitzIndexWeekly", "24__CreateJobUpdateSqlServerVersions",
                "25__CreateJobCheckInstanceAvailability", "26__CreateJobGetAllServerInfo", "27__WhoIsActivePartition",
                "28__BlitzIndexPartition", "29__EnablePageCompression", "30__GrafanaLogin",
                "31__LinkedServerOnInventory", "32__LinkedServerForDataDestinationInstance", "33__AlterViewsForDataDestinationInstance")]
    [String]$StopAtStep,

    [Parameter(Mandatory=$false)]
    [ValidateSet("1__sp_WhoIsActive", "2__AllDatabaseObjects", "3__XEventSession",
                "4__FirstResponderKitObjects", "5__DarlingDataObjects", "6__sp_WhatIsRunning",
                "7__usp_GetAllServerInfo", "8__CopyDbaToolsModule2Host", "9__CopyPerfmonFolder2Host",
                "10__SetupPerfmonDataCollector", "11__CreateCredentialProxy", "12__CreateJobCollectDiskSpace",
                "13__CreateJobCollectOSProcesses", "14__CreateJobCollectPerfmonData", "15__CreateJobCollectWaitStats",
                "16__CreateJobCollectXEvents", "17__CreateJobCollectFileIOStats", "18__CreateJobPartitionsMaintenance",
                "19__CreateJobPurgeTables", "20__CreateJobRemoveXEventFiles", "21__CreateJobRunWhoIsActive",
                "22__CreateJobRunBlitzIndex", "23__CreateJobRunBlitzIndexWeekly", "24__CreateJobUpdateSqlServerVersions",
                "25__CreateJobCheckInstanceAvailability", "26__CreateJobGetAllServerInfo", "27__WhoIsActivePartition",
                "28__BlitzIndexPartition", "29__EnablePageCompression", "30__GrafanaLogin",
                "31__LinkedServerOnInventory", "32__LinkedServerForDataDestinationInstance", "33__AlterViewsForDataDestinationInstance")]
    [String[]]$OnlySteps,

    [Parameter(Mandatory=$false)]
    [PSCredential]$SqlCredential,

    [Parameter(Mandatory=$false)]
    [PSCredential]$WindowsCredential,

    [Parameter(Mandatory=$false)]
    [int]$RetentionDays,

    [Parameter(Mandatory=$false)]
    [bool]$DropCreatePowerShellJobs = $false,

    [Parameter(Mandatory=$false)]
    [bool]$DropCreateWhoIsActiveTable = $false,

    [Parameter(Mandatory=$false)]
    [bool]$SkipPowerShellJobs = $false,

    [Parameter(Mandatory=$false)]
    [bool]$SkipMultiServerviewsUpgrade = $true,

    [Parameter(Mandatory=$false)]
    [bool]$SkipTsqlJobs = $false,

    [Parameter(Mandatory=$false)]
    [bool]$SkipRDPSessionSteps = $false,

    [Parameter(Mandatory=$false)]
    [bool]$SkipWindowsAdminAccessTest = $false,

    [Parameter(Mandatory=$false)]
    [bool]$SkipMailProfileCheck = $false,

    [Parameter(Mandatory=$false)]
    [bool]$SkipCollationCheck = $false,

    [Parameter(Mandatory=$false)]
    [bool]$SkipPageCompression = $false,

    [Parameter(Mandatory=$false)]
    [bool]$ConfirmValidationOfMultiInstance = $false,

    [Parameter(Mandatory=$false)]
    [bool]$DryRun = $false,

    [Parameter(Mandatory=$false)]
    [String]$PreQuery,

    [Parameter(Mandatory=$false)]
    [String]$PostQuery
)

$startTime = Get-Date
$ErrorActionPreference = "Stop"
$sqlmonitorVersion = '1.3.1'
$releaseDiscussionURL = "https://ajaydwivedi.com/sqlmonitor/common-errors"
<#
    v1.3.1 - 2022-Mar-31
        -> Issue#232 - Remove Step 6__OlaHallengrenSolutionObjects
        -> Issue#231 - Alert Based on Central Dashboard using a history Table dbo.all_server_volatile_info_history
        -> Issue#227 - Add CollectionTime of Each Table Data in dbo.all_server_volatile_info on Central Server
    v1.3.0 - 2022-Dec-31
        -> Issue#8 - Dashboard for Database Space Utilization (code done, dash wip)
        -> Issue#62 - Dashboard exposing Resource Consumption (code done, dash wip)
        -> Issue#156 - Panel for Sessions with High Memory Grants (done)
        -> Issue#189 - Monitoring - Live - Distributed Dashboard - Display Cluster Nodes/Replicas (done)
        -> Issue#214 - Store cpu_time in cpu_time_ms in milliseconds (done)
        -> Issue#215 - sp_BlitzIndex - Capture in Mode 0,1,2,4 (code done, dash wip)
    v1.2.1 - 2022-Dec-12
        -> Issue#211 - Capture Unformatted Output - sp_WhoIsActive with @format_output = 0
    v1.2.0 - 2022-Nov-25
        -> Fixed issue#11 - Missing CPU Metrics For Extra SQL Instances on Same Host
#>

"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'START:', "Working on server [$SqlInstanceToBaseline]." | Write-Host -ForegroundColor Yellow
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'START:', "Deploying SQLMonitor v$sqlmonitorVersion.." | Write-Host -ForegroundColor Yellow
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'START:', "For issues with this version, kindly visit $releaseDiscussionURL" | Write-Host -ForegroundColor Yellow
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'START:', "For general support, join #sqlmonitor channel on 'sqlcommunity.slack.com <https://ajaydwivedi.com/go/slack>' workspace.`n" | Write-Host -ForegroundColor Yellow
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'START:', "For paid support, kindly reach out to 'Ajay Dwivedi <ajay.dwivedi2007@gmail.com>'`n" | Write-Host -ForegroundColor Yellow

# All Steps
$AllSteps = @(  "1__sp_WhoIsActive", "2__AllDatabaseObjects", "3__XEventSession",
                "4__FirstResponderKitObjects", "5__DarlingDataObjects", "6__sp_WhatIsRunning",
                "7__usp_GetAllServerInfo", "8__CopyDbaToolsModule2Host", "9__CopyPerfmonFolder2Host",
                "10__SetupPerfmonDataCollector", "11__CreateCredentialProxy", "12__CreateJobCollectDiskSpace",
                "13__CreateJobCollectOSProcesses", "14__CreateJobCollectPerfmonData", "15__CreateJobCollectWaitStats",
                "16__CreateJobCollectXEvents", "17__CreateJobCollectFileIOStats", "18__CreateJobPartitionsMaintenance",
                "19__CreateJobPurgeTables", "20__CreateJobRemoveXEventFiles", "21__CreateJobRunWhoIsActive",
                "22__CreateJobRunBlitzIndex", "23__CreateJobRunBlitzIndexWeekly", "24__CreateJobUpdateSqlServerVersions",
                "25__CreateJobCheckInstanceAvailability", "26__CreateJobGetAllServerInfo", "27__WhoIsActivePartition",
                "28__BlitzIndexPartition", "29__EnablePageCompression", "30__GrafanaLogin",
                "31__LinkedServerOnInventory", "32__LinkedServerForDataDestinationInstance", "33__AlterViewsForDataDestinationInstance")

# TSQL Jobs
$TsqlJobSteps = @(
                "15__CreateJobCollectWaitStats", "16__CreateJobCollectXEvents", "17__CreateJobCollectFileIOStats",
                "18__CreateJobPartitionsMaintenance", "19__CreateJobPurgeTables", "21__CreateJobRunWhoIsActive",
                "20__CreateJobRemoveXEventFiles", "22__CreateJobRunBlitzIndex", "23__CreateJobRunBlitzIndexWeekly")

# PowerShell Jobs
$PowerShellJobSteps = @(
                "12__CreateJobCollectDiskSpace", "13__CreateJobCollectOSProcesses", "14__CreateJobCollectPerfmonData",
                "24__CreateJobUpdateSqlServerVersions", "25__CreateJobCheckInstanceAvailability")

# RDPSessionSteps
$RDPSessionSteps = @("8__CopyDbaToolsModule2Host", "9__CopyPerfmonFolder2Host", "10__SetupPerfmonDataCollector")


# Validate to ensure either of Skip Or Only Steps are provided
if($OnlySteps.Count -gt 0 -and $SkipSteps.Count -gt 0) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Parameters {OnlySteps} & {SkipSteps} are mutually exclusive.`n`tOnly one of these should be provided." | Write-Host -ForegroundColor Red
    Write-Error "Stop here. Fix above issue."
}

# Print warning if OnlySteps are provided
if($OnlySteps.Count -gt 0) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'WARNING:', "Parameter {OnlySteps} has been provided.`n`tThis parameter is mutually exclusive with other parameters.`n`tSo overrides all other parameters." | Write-Host -ForegroundColor Yellow
    Write-Warning "ATTENTION Required on above message."
}


# Add $PowerShellJobSteps to Skip Jobs
if($SkipPowerShellJobs) {
    $SkipSteps = $SkipSteps + $($PowerShellJobSteps | % {if($_ -notin $SkipSteps){$_}});
}

# Add $RDPSessionSteps to Skip Jobs
if($SkipRDPSessionSteps) {
    $SkipSteps = $SkipSteps + $($RDPSessionSteps | % {if($_ -notin $SkipSteps){$_}});
}

# Print Job Step names
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$PowerShellJobSteps => `n`n`t`t`t`t$($PowerShellJobSteps -join "`n`t`t`t`t")`n"
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$RDPSessionSteps => `n`n`t`t`t`t$($RDPSessionSteps -join "`n`t`t`t`t")`n"

# Add $TsqlJobSteps to Skip Jobs
if($SkipTsqlJobs) {
    $SkipSteps = $SkipSteps + $($TsqlJobSteps | % {if($_ -notin $SkipSteps){$_}});
}

# Skip Compression
if($SkipPageCompression -and ('29__EnablePageCompression' -notin $SkipSteps)) {
    $SkipSteps += @('29__EnablePageCompression')
}

# For backward compatability
$SkipAllJobs = $false
if($SkipTsqlJobs -and $SkipPowerShellJobs) {
    $SkipAllJobs = $true
}

"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Clearing old PSSessions.."
Get-PSSession | Remove-PSSession

if($SqlInstanceToBaseline -eq '.' -or $SqlInstanceToBaseline -eq 'localhost') {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "'localhost' or '.' are not validate SQLInstance names." | Write-Host -ForegroundColor Red
    Write-Error "Stop here. Fix above issue."
}

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

# Set windows credential if valid AD credential is provided as SqlCredential
if( [String]::IsNullOrEmpty($WindowsCredential) -and (-not [String]::IsNullOrEmpty($SqlCredential)) -and $SqlCredential.UserName -like "*\*" ) {
    $WindowsCredential = $SqlCredential
}

# Remove end trailer of '\'
if($RemoteSQLMonitorPath.EndsWith('\')) {
    $RemoteSQLMonitorPath = $RemoteSQLMonitorPath.TrimEnd('\')
}

"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$SqlInstanceToBaseline = [$SqlInstanceToBaseline]"
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$SqlCredential => "
$SqlCredential | ft -AutoSize
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$WindowsCredential => "
$WindowsCredential | ft -AutoSize

# Construct File Path Variables
$ddlPath = Join-Path $SQLMonitorPath "DDLs"
$psScriptPath = Join-Path $SQLMonitorPath "SQLMonitor"
$isUpgradeScenario = $false

$mailProfileFilePath = "$ddlPath\$MailProfileFileName"
$WhoIsActiveFilePath = "$ddlPath\$WhoIsActiveFileName"
$AllDatabaseObjectsFilePath = "$ddlPath\$AllDatabaseObjectsFileName"
$InventorySpecificObjectsFilePath = "$ddlPath\$InventorySpecificObjectsFileName"
$XEventSessionFilePath = "$ddlPath\$XEventSessionFileName"
$WhatIsRunningFilePath = "$ddlPath\$WhatIsRunningFileName"
$GetAllServerInfoFilePath = "$ddlPath\$UspGetAllServerInfoFileName"
$UspCollectWaitStatsFilePath = "$ddlPath\$UspCollectWaitStatsFileName"
$UspCollectFileIOStatsFilePath = "$ddlPath\$UspCollectFileIOStatsFileName"
$UspCollectXeventsResourceConsumptionFilePath = "$ddlPath\$UspCollectXeventsResourceConsumptionFileName"
$UspPartitionMaintenanceFilePath = "$ddlPath\$UspPartitionMaintenanceFileName"
$UspPurgeTablesFilePath = "$ddlPath\$UspPurgeTablesFileName"
$UspRunWhoIsActiveFilePath = "$ddlPath\$UspRunWhoIsActiveFileName"
$UspActiveRequestsCountFilePath = "$ddlPath\$UspActiveRequestsCountFileName"
$UspWaitsPerCorePerMinuteFilePath = "$ddlPath\$UspWaitsPerCorePerMinuteFileName"
$UspEnablePageCompressionFilePath = "$ddlPath\$UspEnablePageCompressionFileName"
$WhoIsActivePartitionFilePath = "$ddlPath\$WhoIsActivePartitionFileName"
$BlitzIndexPartitionFilePath = "$ddlPath\$BlitzIndexPartitionFileName"
$GrafanaLoginFilePath = "$ddlPath\$GrafanaLoginFileName"
$CheckInstanceAvailabilityJobFilePath = "$ddlPath\$CheckInstanceAvailabilityJobFileName"
$CollectDiskSpaceJobFilePath = "$ddlPath\$CollectDiskSpaceJobFileName"
$CollectOSProcessesJobFilePath = "$ddlPath\$CollectOSProcessesJobFileName"
$CollectPerfmonDataJobFilePath = "$ddlPath\$CollectPerfmonDataJobFileName"
$CollectWaitStatsJobFilePath = "$ddlPath\$CollectWaitStatsJobFileName"
$CollectFileIOStatsJobFilePath = "$ddlPath\$CollectFileIOStatsJobFileName"
$CollectXEventsJobFilePath = "$ddlPath\$CollectXEventsJobFileName"
$GetAllServerInfoJobFilePath = "$ddlPath\$GetAllServerInfoJobFileName"
$PartitionsMaintenanceJobFilePath = "$ddlPath\$PartitionsMaintenanceJobFileName"
$PurgeTablesJobFilePath = "$ddlPath\$PurgeTablesJobFileName"
$RemoveXEventFilesJobFilePath = "$ddlPath\$RemoveXEventFilesJobFileName"
$RunWhoIsActiveJobFilePath = "$ddlPath\$RunWhoIsActiveJobFileName"
$RunBlitzIndexJobFilePath = "$ddlPath\$RunBlitzIndexJobFileName"
$RunBlitzIndexWeeklyJobFilePath = "$ddlPath\$RunBlitzIndexWeeklyJobFileName"
$UpdateSqlServerVersionsJobFilePath = "$ddlPath\$UpdateSqlServerVersionsJobFileName"
$LinkedServerOnInventoryFilePath = "$ddlPath\$LinkedServerOnInventoryFileName"
$TestWindowsAdminAccessJobFilePath = "$ddlPath\$TestWindowsAdminAccessJobFileName"

"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$ddlPath = '$ddlPath'"
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$psScriptPath = '$psScriptPath'"

"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Import dbatools module.."
Import-Module dbatools
#Import-Module SqlServer

# Compute steps to execute
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Compute Steps to execute.."

# Compute steps to execute
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Compute Steps to execute.."
$StartAtStepNumber = 1
$StopAtStepNumber = $AllSteps.Count+1

if(-not [String]::IsNullOrEmpty($StartAtStep)) {
    [int]$StartAtStepNumber = $StartAtStep -replace "__\w+", ''
}
if(-not [String]::IsNullOrEmpty($StopAtStep)) {
    [int]$StopAtStepNumber = $StopAtStep -replace "__\w+", ''
}


$Steps2Execute = @()
$Steps2ExecuteRaw = @()
if(-not [String]::IsNullOrEmpty($SkipSteps)) {
    $Steps2ExecuteRaw += Compare-Object -ReferenceObject $AllSteps -DifferenceObject $SkipSteps | Where-Object {$_.SideIndicator -eq '<='} | Select-Object -ExpandProperty InputObject -Unique
}
else {
    $Steps2ExecuteRaw += $AllSteps
}

$Steps2Execute += $Steps2ExecuteRaw | ForEach-Object { 
                            $currentStepNumber = [int]$($_ -replace "__\w+", '');
                            $passThrough = $true;
                            if( -not ($currentStepNumber -ge $StartAtStepNumber -and $currentStepNumber -le $StopAtStepNumber) ) {
                                $passThrough = $false
                            }
                            if( $passThrough -and ($SkipAllJobs -and $_ -like '*__CreateJob*') ) {
                                $passThrough = $false
                            }
                            if($passThrough) {$_}
                        }

if($OnlySteps.Count -gt 0) {
    # Override Steps to Execute by OnlySteps parameter value
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Override `$Steps2Execute with value from `$OnlySteps.."
    $Steps2Execute = $OnlySteps
}

"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$StartAtStep -> $StartAtStep.."
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$StopAtStep -> $StopAtStep.."
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Total steps to execute -> $($Steps2Execute.Count)."


# Get Server Info
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Fetching basic server info for `$SqlInstanceToBaseline => [$SqlInstanceToBaseline].."
$sqlServerInfo = @"
DECLARE @Domain NVARCHAR(255);
begin try
	EXEC master.dbo.xp_regread 'HKEY_LOCAL_MACHINE', 'SYSTEM\CurrentControlSet\services\Tcpip\Parameters', N'Domain',@Domain OUTPUT;
end try
begin catch
	print 'some erorr accessing registry'
end catch

select	[domain] = default_domain(),
		[domain_reg] = @Domain,
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
		SERVERPROPERTY('Edition') AS Edition,
        [is_clustered] = case when exists (select 1 from sys.dm_os_cluster_nodes) then 1 else 0 end
from sys.dm_server_services 
where servicename like 'SQL Server (%)'
or servicename like 'SQL Server Agent (%)'
"@
try {
    $resultServerInfo = Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Query $sqlServerInfo -SqlCredential $SqlCredential -EnableException
    $dbServiceInfo = $resultServerInfo | Where-Object {$_.service_name_str -like "SQL Server (*)"}
    $agentServiceInfo = $resultServerInfo | Where-Object {$_.service_name_str -like "SQL Server Agent (*)"}
    $resultServerInfo | Format-Table -AutoSize
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


# Extract Version Info & Partition Info
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Extract Major & Minor Version of SQL Server.."
[bool]$IsNonPartitioned = $true
if($dbServiceInfo.ProductVersion -match "(?'MajorVersion'\d+)\.\d+\.(?'MinorVersion'\d+)\.\d+")
{
    [int]$MajorVersion = $Matches['MajorVersion']
    [int]$MinorVersion = $Matches['MinorVersion']
    [bool]$IsCompressionSupported = $false

    if($dbServiceInfo.Edition -like 'Enterprise*' -or $dbServiceInfo.Edition -like 'Developer*') {
        $IsNonPartitioned = $false
    }
    elseif($dbServiceInfo.Edition -like 'Standard*')
    {
        if($MajorVersion -gt 13) {
            $IsNonPartitioned = $false
        }
        elseif ($MajorVersion -eq 13 -and $MinorVersion -ge 4001) {
            $IsNonPartitioned = $false
        }
    }

    if($MajorVersion -ge 13) {
        $IsCompressionSupported = $true
    }
    elseif ($dbServiceInfo.Edition -like 'Enterprise*' -or $dbServiceInfo.Edition -like 'Developer*') {
        $IsCompressionSupported = $true
    }
}

# Extract domain & isClustered property
[bool]$isClustered = $dbServiceInfo.is_clustered
[string]$domain = $dbServiceInfo.domain_reg
if([String]::IsNullOrEmpty($domain)) {
    if($dbServiceInfo.domain -ne 'WORKGROUP') {
        $domain = $dbServiceInfo.domain+'.com'
    }
    else {
        $domain = $dbServiceInfo.domain
    }
}

# Get dbo.instance_details info
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Fetching info from [dbo].[instance_details].."
$instanceDetails = @()
if([String]::IsNullOrEmpty($HostName)) {
    $sqlInstanceDetails = "select * from dbo.instance_details where sql_instance = '$SqlInstanceToBaseline'"
}
else {
    $sqlInstanceDetails = "select * from dbo.instance_details where sql_instance = '$SqlInstanceToBaseline' and [host_name] = '$HostName'"
}
try {
    $instanceDetails += Invoke-DbaQuery -SqlInstance $InventoryServer -Database $InventoryDatabase -Query $sqlInstanceDetails -SqlCredential $SqlCredential
    if($instanceDetails.Count -eq 0) {
        $instanceDetails += Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -Query $sqlInstanceDetails -SqlCredential $SqlCredential -EnableException
    }
}
catch {
    $errMessage = $_

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Could not fetch details from dbo.instance_details info."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "So assuming fresh installation of SQLMonitor."
}

# If instance details found, then use same to initiate empty parameters
if ( $instanceDetails.Count -gt 0 ) 
{
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Instance details found in [dbo].[instance_details]."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Using available info from this table."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Incase details of [dbo].[instance_details] are outdated, `n`t`t`t`tconsider updating same 1st on Inventory & Local Instance both."
    $instanceDetails | ft -AutoSize

    # If more than 1 host is found, then confirm from user
    if ( $instanceDetails.Count -gt 1 ) 
    {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Multiple Hosts detected for SqlInstance [$SqlInstanceToBaseline]." | Write-Host -ForegroundColor Red
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Kindly specify HostName parameter related to SqlInstance [$SqlInstanceToBaseline]." | Write-Host -ForegroundColor Red
        
        "STOP here, and fix above issue." | Write-Error
    }    

    # If no DBA Mail provided, then fetch from dbo.instance_details
    if($DbaGroupMailId.Count -eq 0) {
        $DbaGroupMailId += $($instanceDetails.dba_group_mail_id -split ';')
    }

    if( ($RemoteSQLMonitorPath -ne $instanceDetails.sqlmonitor_script_path) -and $RemoteSQLMonitorPath -ne 'C:\SQLMonitor' ) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "RemoteSQLMonitorPath parameter value does not match with dbo.instance_details." | Write-Host -ForegroundColor Red
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Consider updating details of dbo.instance_details on Inventory & Local Instance both."
        
        "STOP here, and fix above issue." | Write-Error
    }else {
        if( ($RemoteSQLMonitorPath -ne $instanceDetails.sqlmonitor_script_path) -and $RemoteSQLMonitorPath -eq 'C:\SQLMonitor' ) {
            $RemoteSQLMonitorPath = $instanceDetails.sqlmonitor_script_path
        }
    }

    if ([String]::IsNullOrEmpty($SqlInstanceAsDataDestination)) {
        $SqlInstanceAsDataDestination = $instanceDetails.data_destination_sql_instance
    }
    else {
        if( $SqlInstanceAsDataDestination -ne $instanceDetails.data_destination_sql_instance ) {
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "SqlInstanceAsDataDestination parameter value does not match with dbo.instance_details." | Write-Host -ForegroundColor Red
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Consider updating details of dbo.instance_details on Inventory & Local Instance both."
        
            "STOP here, and fix above issue." | Write-Error
        }
    }

    if ([String]::IsNullOrEmpty($SqlInstanceForPowershellJobs)) {
        $SqlInstanceForPowershellJobs = $instanceDetails.collector_powershell_jobs_server
    }
    else {
        if( $SqlInstanceForPowershellJobs -ne $instanceDetails.collector_powershell_jobs_server ) {
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "SqlInstanceForPowershellJobs parameter value does not match with dbo.instance_details." | Write-Host -ForegroundColor Red
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Consider updating details of dbo.instance_details on Inventory & Local Instance both."
        
            "STOP here, and fix above issue." | Write-Error
        }
    }

    if ($DbaGroupMailId.Count -eq 0) {
        $DbaGroupMailId += 'some_dba_mail_id@gmail.com'
    }
    
    if ([String]::IsNullOrEmpty($SqlInstanceForTsqlJobs)) {
        $SqlInstanceForTsqlJobs = $instanceDetails.collector_tsql_jobs_server
    }
    else {
        if( $SqlInstanceForTsqlJobs -ne $instanceDetails.collector_tsql_jobs_server ) {
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "SqlInstanceForTsqlJobs parameter value does not match with dbo.instance_details." | Write-Host -ForegroundColor Red
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Consider updating details of dbo.instance_details on Inventory & Local Instance both."
        
            "STOP here, and fix above issue." | Write-Error
        }
    }

    if( ($DbaDatabase -ne $instanceDetails.database) -and $DbaDatabase -ne 'DBA' ) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "DbaDatabase parameter value does not match with dbo.instance_details." | Write-Host -ForegroundColor Red
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Consider updating details of dbo.instance_details on Inventory & Local Instance both."
        
        "STOP here, and fix above issue." | Write-Error
    }else {
        if( ($DbaDatabase -ne $instanceDetails.database) -and $DbaDatabase -eq 'DBA' ) {
            $DbaDatabase = $instanceDetails.database
        }
    }

    if(-not $ConfirmValidationOfMultiInstance) {
        $ConfirmValidationOfMultiInstance = $true
    }

    $isUpgradeScenario = $true
}

# If fresh install, then set SkipMultiServerviewsUpgrade to False
if(-not $isUpgradeScenario) {
    $SkipMultiServerviewsUpgrade = $false
}

if($DbaGroupMailId -eq 'some_dba_mail_id@gmail.com') {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Kindly provide a valid value for DbaGroupMailId parameter." | Write-Host -ForegroundColor Red
    Write-Error "Stop here. Fix above issue."
}


# Fetch HostName for SqlInstance if NULL in parameter value
if([String]::IsNullOrEmpty($HostName)) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Extract HostName of SQL Server Instance.."
    $HostName = $dbServiceInfo.host_name;
}
else {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Validate HostName.."
    # If Sql Cluster, then host can be different
    # If not sql cluster, then host should be same
    if(-not $isClustered) {
        if($HostName -ne $dbServiceInfo.host_name) {
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Provided HostName does not match with SQLInstance host name." | Write-Host -ForegroundColor Red
            "STOP and check above error message" | Write-Error
        }
    }
}

# Setup PSSession on HostName to setup Perfmon Data Collector. $ssn4PerfmonSetup
if( (-not $SkipRDPSessionSteps) ) #-and ($HostName -ne $env:COMPUTERNAME)
{
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Create PSSession for host [$HostName].."
    $ssnHostName = $HostName

    # Try reaching server using HostName provided/detected, if fails, then use FQDN
    if (-not (Test-Connection -ComputerName $ssnHostName -Quiet -Count 1)) {
        if($domain -ne 'WORKGROUP.com' -and $domain -ne 'WORKGROUP') {
            $ssnHostName = "$HostName.$domain"
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'WARNING:', "Host [$HostName] not pingable. So trying FQDN form [$ssnHostName].."
        }
    }

    # Try reaching using FQDN, if fails & not a clustered instance, then use SqlInstanceToBaseline itself
    if ( (-not (Test-Connection -ComputerName $ssnHostName -Quiet -Count 1)) -and (-not $isClustered) ) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'WARNING:', "Host [$ssnHostName] not pingable. Since its not clustered instance, So trying `$SqlInstanceToBaseline parameter value itself.."
        $ssnHostName = $SqlInstanceToBaseline
    }

    # If not reachable after all attempts, raise error
    if ( -not (Test-Connection -ComputerName $ssnHostName -Quiet -Count 1) ) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Host [$ssnHostName] not pingable." | Write-Host -ForegroundColor Red
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Kindly provide HostName either in FQDN or ipv4 format." | Write-Host -ForegroundColor Red
        "STOP and check above error message" | Write-Error
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$ssnHostName => '$ssnHostName'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Domain of SqlInstance being baselined => [$domain]"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Domain of current host => [$($env:USERDOMAIN)]"

    $ssn4PerfmonSetup = $null
    $errVariables = @()

    # First Attempt without Any credentials
    try {
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Trying for PSSession on [$ssnHostName] normally.."
            $ssn4PerfmonSetup = New-PSSession -ComputerName $ssnHostName 
        }
    catch { $errVariables += $_ }

    # Second Attempt for Trusted Cross Domains
    if( [String]::IsNullOrEmpty($ssn4PerfmonSetup) ) {
        try { 
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Trying for PSSession on [$ssnHostName] assuming cross domain.."
            $ssn4PerfmonSetup = New-PSSession -ComputerName $ssnHostName -Authentication Negotiate 
        }
        catch { $errVariables += $_ }
    }

    # 3rd Attempt with Credentials
    if( [String]::IsNullOrEmpty($ssn4PerfmonSetup) -and (-not [String]::IsNullOrEmpty($WindowsCredential)) ) {
        try {
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Attemping PSSession for [$ssnHostName] using provided WindowsCredentials.."
            $ssn4PerfmonSetup = New-PSSession -ComputerName $ssnHostName -Credential $WindowsCredential    
        }
        catch { $errVariables += $_ }

        if( [String]::IsNullOrEmpty($ssn4PerfmonSetup) ) {
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Attemping PSSession for [$ssnHostName] using provided WindowsCredentials with Negotiate attribute.."
            $ssn4PerfmonSetup = New-PSSession -ComputerName $ssnHostName -Credential $WindowsCredential -Authentication Negotiate
        }
    }

    if ( [String]::IsNullOrEmpty($ssn4PerfmonSetup) ) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Provide WindowsCredential for accessing server [$ssnHostName] of domain '$domain'." | Write-Host -ForegroundColor Red
        "STOP here, and fix above issue." | Write-Error
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$ssn4PerfmonSetup PSSession for [$HostName].."
    $ssn4PerfmonSetup
    "`n"
}

# Validate if IPv4 is provided instead of DNS name for HostName
$pattern = "^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$"
if($HostName  -match $pattern) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "IP address has been provided for `$HostName parameter."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Fetching DNS name for [$HostName].."
    $HostName = Invoke-Command -Session $ssn4PerfmonSetup -ScriptBlock { $env:COMPUTERNAME }
}

# Validate if FQDN is provided instead of single part HostName
$pattern = "(?=^.{4,253}$)(^((?!-)[a-zA-Z0-9-]{1,63}(?<!-)\.)+[a-zA-Z]{2,63}$)"
if($HostName  -match $pattern) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "FQDN has been provided for `$HostName parameter."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Fetching DNS name for [$HostName].."
    $HostName = Invoke-Command -Session $ssn4PerfmonSetup -ScriptBlock { $env:COMPUTERNAME }
}

# Check No of SQL Services on HostName
if( ($SkipPowerShellJobs -eq $false) -or ('20__CreateJobRemoveXEventFiles' -in $Steps2Execute) )
{
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Check for number of SQLServices on [$HostName].."

    $sqlServicesOnHost = @()

    # Localhost system
    if( $HostName -eq $env:COMPUTERNAME ) {
        $sqlServicesOnHost += Get-Service MSSQL* | Where-Object {$_.DisplayName -like 'SQL Server (*)' -and $_.StartType -ne 'Disabled'}
    }
    
    # Remote host
    if($HostName -ne $env:COMPUTERNAME)
    {
        # if pssession is null
        if([String]::IsNullOrEmpty($ssn4PerfmonSetup)) 
        {
            # If Destination instance is not provided, throw error
            if([String]::IsNullOrEmpty($SqlInstanceAsDataDestination) -or (-not $ConfirmValidationOfMultiInstance)) {
                "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Kindly provide values for parameter SqlInstanceAsDataDestination & ConfirmValidationOfMultiInstance as `$ssn4PerfmonSetup is null." | Write-Host -ForegroundColor Red
                "STOP here, and fix above issue." | Write-Error
            }
        }
        
        # if pssession is not null
        if(-not [String]::IsNullOrEmpty($ssn4PerfmonSetup)) {
        $sqlServicesOnHost += Invoke-Command -Session $ssn4PerfmonSetup -ScriptBlock { 
                                    Get-Service MSSQL* | Where-Object {$_.DisplayName -like 'SQL Server (*)' -and $_.StartType -ne 'Disabled'} 
                            }
        }
    }

    # If more than one sql services found, then ensure appropriate parameters are provided
    if($sqlServicesOnHost.Count -gt 1) 
    {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "[$($sqlServicesOnHost.Count)] database engine Services found on [$HostName].."

        # If Destination instance is not provided, throw error
        if([String]::IsNullOrEmpty($SqlInstanceAsDataDestination) -or (-not $ConfirmValidationOfMultiInstance)) 
        {
            if([String]::IsNullOrEmpty($SqlInstanceAsDataDestination)) {
                "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Kindly provide value for parameter SqlInstanceAsDataDestination as host has multiple database engine services, `n`t and Perfmon data can be saved on only on one SQLInstance." | Write-Host -ForegroundColor Red
            }
            if(-not $ConfirmValidationOfMultiInstance) {
                "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Kindly set ConfirmValidationOfMultiInstance parameter to true as host has multiple database engine services, `n`t and Perfmon data can be saved on only on one SQLInstance." | Write-Host -ForegroundColor Red
            }

            "STOP here, and fix above issue." | Write-Error
        }
        # If destination is provided, then validate if perfmon is not already get collected
        else {
            
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Validate if Perfmon data is not being collected already on [$SqlInstanceAsDataDestination] for same host.."
            $sqlPerfmonRecord = @"
if OBJECT_ID('dbo.performance_counters') is not null
begin
	select top 1 'dbo.performance_counters' as QueryData, getutcdate() as current_time_utc, collection_time_utc, pc.host_name
	from dbo.performance_counters pc with (nolock)
	where pc.collection_time_utc >= DATEADD(minute,-20,GETUTCDATE()) and host_name = '$HostName'
	order by pc.collection_time_utc desc
end
"@
            $resultPerfmonRecord = @()
            $resultPerfmonRecord += Invoke-DbaQuery -SqlInstance $SqlInstanceAsDataDestination -Database $DbaDatabase -Query $sqlPerfmonRecord -SqlCredential $SqlCredential -EnableException
            if($resultPerfmonRecord.Count -eq 0) {
                "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "No Perfmon data record found for last 20 minutes for host [$HostName] on [$SqlInstanceAsDataDestination]."
            }
            else {
                "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'WARNING:', "Perfmon data records of latest 20 minutes for host [$HostName] are present on [$SqlInstanceAsDataDestination]."
            }
        }
    }
}

# Set $SqlInstanceAsDataDestination same as $SqlInstanceToBaseline if NULL
if([String]::IsNullOrEmpty($SqlInstanceAsDataDestination)) {
    $SqlInstanceAsDataDestination = $SqlInstanceToBaseline
}

# Set $SqlInstanceForTsqlJobs same as $SqlInstanceToBaseline if NULL
if([String]::IsNullOrEmpty($SqlInstanceForTsqlJobs)) {
    $SqlInstanceForTsqlJobs = $SqlInstanceToBaseline
}

# Set $SqlInstanceForPowershellJobs same as $SqlInstanceToBaseline if NULL
if([String]::IsNullOrEmpty($SqlInstanceForPowershellJobs)) {
    $SqlInstanceForPowershellJobs = $SqlInstanceToBaseline
}

"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$DbaDatabase = [$DbaDatabase]" | Write-Host -ForegroundColor Yellow
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$isUpgradeScenario = [$isUpgradeScenario]" | Write-Host -ForegroundColor Yellow
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$SqlInstanceAsDataDestination = [$SqlInstanceAsDataDestination]"
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$SqlInstanceForTsqlJobs = [$SqlInstanceForTsqlJobs]"
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$SqlInstanceForPowershellJobs = [$SqlInstanceForPowershellJobs]"


# If Express edition, then ensure another server is mentioned for Creating jobs
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Checking if [$SqlInstanceToBaseline] is Express Edition.."
$isExpressEdition = $false
if($dbServiceInfo.Edition -like 'Express*') {
    $isExpressEdition = $true
    if( ($SqlInstanceForTsqlJobs -eq $SqlInstanceToBaseline) -or ($SqlInstanceForPowershellJobs -eq $SqlInstanceToBaseline) ) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Curent instance is Express edition. `n`tKindly provide a different SQLInstance for parameters SqlInstanceForTsqlJobs & SqlInstanceForPowershellJobs." | Write-Host -ForegroundColor Red
        "STOP and check above error message" | Write-Error
    }
}


# Validate database collation
if(-not $SkipCollationCheck) 
{
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
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Kindly rectify this collation problem, or Using SkipCollationCheck parameter." | Write-Host -ForegroundColor Red
        $dbCollationResult | Format-Table -AutoSize #| Write-Host -ForegroundColor Red
        Write-Error "Stop here. Fix above issue."
    }
}


# Get HostName for $SqlInstanceForPowershellJobs
if($SqlInstanceToBaseline -ne $SqlInstanceForPowershellJobs) 
{
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Fetching basic info for `$SqlInstanceForPowershellJobs => [$SqlInstanceForPowershellJobs].."
    try {
        $jobServerServicesInfo = Invoke-DbaQuery -SqlInstance $SqlInstanceForPowershellJobs -Query $sqlServerInfo -SqlCredential $SqlCredential -EnableException
        $jobServerDbServiceInfo = $jobServerServicesInfo | Where-Object {$_.service_name_str -like "SQL Server (*)"}
        $jobServerAgentServiceInfo = $jobServerServicesInfo | Where-Object {$_.service_name_str -like "SQL Server Agent (*)"}
        $jobServerServicesInfo | Format-Table -AutoSize
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
}
else {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$SqlInstanceToBaseline ~ `$SqlInstanceForPowershellJobs.."
    $jobServerServicesInfo = $resultServerInfo
    $jobServerDbServiceInfo = $dbServiceInfo
    $jobServerAgentServiceInfo = $agentServiceInfo
}


# Setup PSSession on $SqlInstanceForPowershellJobs
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Validating if PSSession is needed on `$SqlInstanceForPowershellJobs.."
if( (-not $SkipRDPSessionSteps) -and ($HostName -ne $jobServerDbServiceInfo.host_name) )
{
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Create PSSession for host [$($jobServerDbServiceInfo.host_name)].."
    $ssnHostName = $jobServerDbServiceInfo.host_name #+'.'+$jobServerDbServiceInfo.domain_reg

    # Try reaching server using HostName provided/detected, if fails, then use FQDN
    if (-not (Test-Connection -ComputerName $ssnHostName -Quiet -Count 1)) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'WARNING:', "Host [$ssnHostName] not pingable. So trying FQDN form.."
        $ssnHostName = $ssnHostName+'.'+$jobServerDbServiceInfo.domain_reg
    }

    # Try reaching using FQDN, if fails & not a clustered instance, then use SqlInstanceToBaseline itself
    if (-not (Test-Connection -ComputerName $ssnHostName -Quiet -Count 1)) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'WARNING:', "Host [$ssnHostName] not pingable. So trying `$SqlInstanceForPowershellJobs parameter value itself.."
        $ssnHostName = $SqlInstanceForPowershellJobs
    }

    # Try reaching using FQDN, if fails & not a clustered instance, then use SqlInstanceToBaseline itself
    if ( -not (Test-Connection -ComputerName $ssnHostName -Quiet -Count 1) ) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Host [$ssnHostName] not pingable." | Write-Host -ForegroundColor Red
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Kindly ensure pssession is working for `$SqlInstanceForPowershellJobs [$SqlInstanceForPowershellJobs]." | Write-Host -ForegroundColor Red
        "STOP and check above error message" | Write-Error
    }

    $ssnJobServer = $null
    $errVariables = @()

    # First Attempt without Any credentials
    try {
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Trying for PSSession on [$ssnHostName] normally.."
            $ssnJobServer = New-PSSession -ComputerName $ssnHostName 
        }
    catch { $errVariables += $_ }

    # Second Attempt for Trusted Cross Domains
    if( [String]::IsNullOrEmpty($ssnJobServer) ) {
        try { 
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Trying for PSSession on [$ssnHostName] assuming cross domain.."
            $ssnJobServer = New-PSSession -ComputerName $ssnHostName -Authentication Negotiate 
        }
        catch { $errVariables += $_ }
    }

    # 3rd Attempt with Credentials
    if( [String]::IsNullOrEmpty($ssnJobServer) -and (-not [String]::IsNullOrEmpty($WindowsCredential)) ) {
        try {
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Attemping PSSession for [$ssnHostName] using provided WindowsCredentials.."
            $ssnJobServer = New-PSSession -ComputerName $ssnHostName -Credential $WindowsCredential    
        }
        catch { $errVariables += $_ }

        if( [String]::IsNullOrEmpty($ssn) ) {
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Attemping PSSession for [$ssnHostName] using provided WindowsCredentials with Negotiate attribute.."
            $ssnJobServer = New-PSSession -ComputerName $ssnHostName -Credential $WindowsCredential -Authentication Negotiate
        }
    }

    if ( [String]::IsNullOrEmpty($ssnJobServer) ) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Provide WindowsCredential for accessing server [$ssnHostName] of domain '$($sqlServerInfo.domain)'." | Write-Host -ForegroundColor Red
        "STOP here, and fix above issue." | Write-Error
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "PSSession for [$($jobServerDbServiceInfo.host_name)].."
    $ssnJobServer
}
else {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$ssnJobServer is same as `$ssn4PerfmonSetup."
    $ssnJobServer = $ssn4PerfmonSetup
}


# Service Account and Access Validation
$requireProxy = $false
if( ($SkipPowerShellJobs -or $SkipAllJobs) -and ($SkipWindowsAdminAccessTest -eq $false) -and ('20__CreateJobRemoveXEventFiles' -notin $Steps2Execute) ) { $SkipWindowsAdminAccessTest = $true }
if($SkipWindowsAdminAccessTest -eq $false)
{
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Validate for WindowsCredential if SQL Service Accounts are non-priviledged.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$TestWindowsAdminAccessJobFilePath = '$TestWindowsAdminAccessJobFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating & executing job [(dba) Test-WindowsAdminAccess] on [$SqlInstanceForPowershellJobs].."
    $sqlTestWindowsAdminAccessFilePath = [System.IO.File]::ReadAllText($TestWindowsAdminAccessJobFilePath)
    Invoke-DbaQuery -SqlInstance $SqlInstanceForPowershellJobs -Database msdb -Query $sqlTestWindowsAdminAccessFilePath -SqlCredential $SqlCredential -EnableException

    $testWindowsAdminAccessJobHistory = @()
    $loopStartTime = Get-Date
    $sleepDurationSeconds = 5
    $loopTotalDurationThresholdSeconds = 300    
    
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Fetching execution history for job [(dba) Test-WindowsAdminAccess] on [$SqlInstanceForPowershellJobs].."
    while ($testWindowsAdminAccessJobHistory.Count -eq 0 -and $( (New-TimeSpan $loopStartTime $(Get-Date)).TotalSeconds -le $loopTotalDurationThresholdSeconds ) )
    {
        $testWindowsAdminAccessJobHistory += Get-DbaAgentJobHistory -SqlInstance $SqlInstanceForPowershellJobs -Job '(dba) Test-WindowsAdminAccess' `
                                                    -ExcludeJobSteps -SqlCredential $SqlCredential -EnableException

        if($testWindowsAdminAccessJobHistory.Count -eq 0) {
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Wait for $sleepDurationSeconds seconds as the job might be running.."
            Start-Sleep -Seconds $sleepDurationSeconds
        }
    }

    if($testWindowsAdminAccessJobHistory.Count -eq 0) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Status of job [(dba) Test-WindowsAdminAccess] on [$SqlInstanceForPowershellJobs] could not be fetched on time. Kindly validate." | Write-Host -ForegroundColor Red
        "STOP and check above error message" | Write-Error
    }
    else {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "[(dba) Test-WindowsAdminAccess] Job history => '$($testWindowsAdminAccessJobHistory.Message)'."
        $testWindowsAdminAccessJobHistory | Format-Table -AutoSize
    }

    $hasWindowsAdminAccess = $false
    $sqlServerAgentInfo = if($SqlInstanceForPowershellJobs -ne $SqlInstanceToBaseline) {$jobServerAgentServiceInfo} else {$agentServiceInfo}

    if($testWindowsAdminAccessJobHistory.Status -ne 'Succeeded') {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "SQL Agent service account [$($sqlServerAgentInfo.service_account)] DO NOT have admin access at windows."
    } else {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "SQL Agent service account [$($sqlServerAgentInfo.service_account)] has admin access at windows."
        $hasWindowsAdminAccess = $true
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Remove test job [(dba) Test-WindowsAdminAccess].."
    Invoke-DbaQuery -SqlInstance $SqlInstanceForPowershellJobs -Database msdb -Query "EXEC msdb.dbo.sp_delete_job @job_name=N'(dba) Test-WindowsAdminAccess'" -SqlCredential $SqlCredential -EnableException


    $requireProxy = $(-not $hasWindowsAdminAccess)
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$hasWindowsAdminAccess = $hasWindowsAdminAccess"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$requireProxy = $requireProxy"

    if($requireProxy -and [String]::IsNullOrEmpty($WindowsCredential)) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Kindly provide WindowsCredential to create SQL Agent Job Proxy." | Write-Host -ForegroundColor Red
        "STOP and check above error message" | Write-Error
    }
}
else {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'WARNING:', "Since SkipWindowsAdminAccessTest is set to TRUE, assuming `$requireProxy to $requireProxy."
}


# Validate mail profile
if(-not $SkipMailProfileCheck)
{
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
}


# Execute PreQuery
if(-not [String]::IsNullOrEmpty($PreQuery)) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Executing PreQuery on [$SqlInstanceToBaseline].." | Write-Host -ForegroundColor Cyan
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -Query $PreQuery -SqlCredential $SqlCredential -EnableException
}


# 1__sp_WhoIsActive
$stepName = '1__sp_WhoIsActive'
if($stepName -in $Steps2Execute) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$WhoIsActiveFilePath = '$WhoIsActiveFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating sp_WhoIsActive in [master] database.."
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database master -File $WhoIsActiveFilePath -SqlCredential $SqlCredential -EnableException

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Checking if sp_WhoIsActive is present in [$DbaDatabase] also.."
    $sqlCheckWhoIsActiveExistence = "select [is_existing] = case when OBJECT_ID('dbo.sp_WhoIsActive') is null then 0 else 1 end;"
    $existsWhoIsActive = Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -Query $sqlCheckWhoIsActiveExistence -SqlCredential $SqlCredential -EnableException | Select-Object -ExpandProperty is_existing;
    if($existsWhoIsActive -eq 1) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Update sp_WhoIsActive definition in [$DbaDatabase] also.."
        Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -File $WhoIsActiveFilePath -SqlCredential $SqlCredential -EnableException
    }
}

# Fetch DBA Database File Path
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Fetch [$DbaDatabase] path.."
$sqlDbaDatabasePath = @"
select top 1 physical_name FROM sys.master_files 
where database_id = DB_ID('$DbaDatabase') and type_desc = 'ROWS' 
and physical_name not like 'C:\%' order by file_id;
"@
$resultDbaDatabasePath = @()
$resultDbaDatabasePath += Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database master -SqlCredential $SqlCredential -Query $sqlDbaDatabasePath -EnableException
if($resultDbaDatabasePath.Count -eq 0) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Seems either [$DbaDatabase] does not exists, or the data/log files are present in C:\ drive. `n`t Kindly rectify this issue." | Write-Host -ForegroundColor Red
    Write-Error "Stop here. Fix above issue."
}
else {
    $dbaDatabasePath = $resultDbaDatabasePath[0].physical_name
}
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$dbaDatabasePath => '$dbaDatabasePath'.."


# 2__AllDatabaseObjects
$stepName = '2__AllDatabaseObjects'
if($stepName -in $Steps2Execute)
{
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating All Objects in [$DbaDatabase] database.."

    # Retrieve actual content & dump in temporary file
    $tempAllDatabaseObjectsFileName = "$($AllDatabaseObjectsFileName -replace '.sql','')-RuntimeUsedFile.sql"
    $tempAllDatabaseObjectsFilePath = Join-Path $ddlPath $tempAllDatabaseObjectsFileName

    $AllDatabaseObjectsFileContent = [System.IO.File]::ReadAllText($AllDatabaseObjectsFilePath)

    # MultiServerViews ~ [vw_performance_counters],[vw_disk_space],[vw_os_task_list]
    if($SkipMultiServerviewsUpgrade -eq $true) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "MultiServerViews are being skipped for upgrade."
        $AllDatabaseObjectsFileContent = $AllDatabaseObjectsFileContent.Replace("declare @recreate_multi_server_views bit = 1;", "declare @recreate_multi_server_views bit = 0;")
    }
    else {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "MultiServerViews are considered for upgrade."
    }

    # Modify content if SQL Server does not support Partitioning
    if($IsNonPartitioned) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Partitioning is not supported on current server."

        $AllDatabaseObjectsFileContent = $AllDatabaseObjectsFileContent.Replace('declare @is_partitioned bit = 1;', 'declare @is_partitioned bit = 0;')
        $AllDatabaseObjectsFileContent = $AllDatabaseObjectsFileContent.Replace(' on ps_dba', ' --on ps_dba')
    }

    $AllDatabaseObjectsFileContent | Out-File -FilePath $tempAllDatabaseObjectsFilePath
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Runtime All Server Objects file code is generated."

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$AllDatabaseObjectsFilePath = '$tempAllDatabaseObjectsFilePath'"
    try {
        Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -File $tempAllDatabaseObjectsFilePath -SqlCredential $SqlCredential -EnableException
    }
    catch {
        $errMessage = $_

        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Below error occurred while trying to execute script '$tempAllDatabaseObjectsFilePath'." | Write-Host -ForegroundColor Red
        $($errMessage.Exception.Message -Split [Environment]::NewLine) | % {"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "$_"} | Write-Host -ForegroundColor Red

        Write-Error "Stop here. Fix above issue."
    }

    # Cleanup temporary file path
    if($true) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Remove temp file '$tempAllDatabaseObjectsFilePath'.."
        Remove-Item -Path $tempAllDatabaseObjectsFilePath | Out-Null
    }

    # Update InventoryServer Objects
    if($InventoryServer -eq $SqlInstanceToBaseline)
    {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Update objects on Inventory Server.."
        $InventorySpecificObjectsFileText = [System.IO.File]::ReadAllText($InventorySpecificObjectsFilePath)
        $dbaDatabaseParentPath = Split-Path $dbaDatabasePath -Parent
        $memoryOptimizedFilePath = if($dbaDatabaseParentPath -notmatch '\\$') { "$dbaDatabaseParentPath\MemoryOptimized.ndf" } else { "$($dabaDatabaseParentPath)MemoryOptimized.ndf" }
        #$InventorySpecificObjectsFileText = $InventorySpecificObjectsFileText.Replace('E:\Data\MemoryOptimized.ndf', "$(Join-Path $dbaDatabaseParentPath 'MemoryOptimized.ndf')")
        $InventorySpecificObjectsFileText = $InventorySpecificObjectsFileText.Replace('E:\Data\MemoryOptimized.ndf', $memoryOptimizedFilePath)
        Invoke-DbaQuery -SqlInstance $InventoryServer -Database $InventoryDatabase -Query $InventorySpecificObjectsFileText -SqlCredential $SqlCredential -EnableException
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$UspCollectWaitStatsFilePath = '$UspCollectWaitStatsFilePath'"
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -File $UspCollectWaitStatsFilePath -SqlCredential $SqlCredential -EnableException

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$UspCollectXeventsResourceConsumptionFilePath = '$UspCollectXeventsResourceConsumptionFilePath'"
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -File $UspCollectXeventsResourceConsumptionFilePath -SqlCredential $SqlCredential -EnableException

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$UspPartitionMaintenanceFilePath = '$UspPartitionMaintenanceFilePath'"
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -File $UspPartitionMaintenanceFilePath -SqlCredential $SqlCredential -EnableException

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$UspPurgeTablesFilePath = '$UspPurgeTablesFilePath'"
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -File $UspPurgeTablesFilePath -SqlCredential $SqlCredential -EnableException

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$UspActiveRequestsCountFilePath = '$UspActiveRequestsCountFilePath'"
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -File $UspActiveRequestsCountFilePath -SqlCredential $SqlCredential -EnableException

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$UspWaitsPerCorePerMinuteFilePath = '$UspWaitsPerCorePerMinuteFilePath'"
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -File $UspWaitsPerCorePerMinuteFilePath -SqlCredential $SqlCredential -EnableException

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$UspEnablePageCompressionFilePath = '$UspEnablePageCompressionFilePath'"
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -File $UspEnablePageCompressionFilePath -SqlCredential $SqlCredential -EnableException

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$UspRunWhoIsActiveFilePath = '$UspRunWhoIsActiveFilePath'"
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -File $UspRunWhoIsActiveFilePath -SqlCredential $SqlCredential -EnableException

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$UspCollectFileIOStatsFilePath = '$UspCollectFileIOStatsFilePath'"
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -File $UspCollectFileIOStatsFilePath -SqlCredential $SqlCredential -EnableException

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Adding entry into [$SqlInstanceToBaseline].[$DbaDatabase].[dbo].[instance_hosts].."
    $sqlAddInstanceHost = @"
        if not exists (select * from dbo.instance_hosts where host_name = '$HostName')
        begin
	        insert dbo.instance_hosts ([host_name])
	        select [host_name] = '$HostName';
            
            select 'dbo.instance_hosts' as RunningQuery, * from dbo.instance_hosts where [host_name] = '$HostName';
        end
"@
    # Populate $SqlInstanceToBaseline
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -Query $sqlAddInstanceHost -SqlCredential $SqlCredential -EnableException | ft -AutoSize

    # Populate $SqlInstanceAsDataDestination
    if( ($SqlInstanceAsDataDestination -ne $SqlInstanceToBaseline) -and ($InventoryServer -ne $SqlInstanceAsDataDestination) ) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Adding entry into [$SqlInstanceAsDataDestination].[$DbaDatabase].[dbo].[instance_hosts].."
        Invoke-DbaQuery -SqlInstance $SqlInstanceAsDataDestination -Database $DbaDatabase -Query $sqlAddInstanceHost -SqlCredential $SqlCredential -EnableException | ft -AutoSize
    }

    # Populate $InventoryServer
    if($InventoryServer -ne $SqlInstanceToBaseline) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Adding entry into [$InventoryServer].[$InventoryDatabase].[dbo].[instance_hosts].."
        Invoke-DbaQuery -SqlInstance $InventoryServer -Database $InventoryDatabase -Query $sqlAddInstanceHost -SqlCredential $SqlCredential -EnableException | ft -AutoSize
    }


    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Adding entry into [$SqlInstanceToBaseline].[$DbaDatabase].[dbo].[instance_details].."
    $sqlAddInstanceHostMapping = @"
    if not exists (select * from dbo.instance_details where sql_instance = '$SqlInstanceToBaseline' and [host_name] = '$HostName')
    begin
	    insert dbo.instance_details 
            (   [sql_instance], [host_name], [database], [collector_tsql_jobs_server], 
                [collector_powershell_jobs_server], [data_destination_sql_instance],
                [dba_group_mail_id], [sqlmonitor_script_path]
            )
	    select	[sql_instance] = '$SqlInstanceToBaseline',
			    [host_name] = '$Hostname',
                [database] = '$DbaDatabase',
			    [collector_tsql_jobs_server] = '$SqlInstanceForTsqlJobs',
                [collector_powershell_jobs_server] = '$SqlInstanceForPowershellJobs',
                [data_destination_sql_instance] = '$SqlInstanceAsDataDestination',
                [dba_group_mail_id] = '$($DbaGroupMailId -join ';')',
			    [sqlmonitor_script_path] = '$RemoteSQLMonitorPath'

        select 'dbo.instance_details' as RunningQuery, * from dbo.instance_details where [sql_instance] = '$SqlInstanceToBaseline';
    end
"@
    
    # Populate $SqlInstanceToBaseline
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -Query $sqlAddInstanceHostMapping -SqlCredential $SqlCredential -EnableException | ft -AutoSize

    # Populate $SqlInstanceAsDataDestination
    if( ($SqlInstanceAsDataDestination -ne $SqlInstanceToBaseline) -and ($InventoryServer -ne $SqlInstanceAsDataDestination) ) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Adding entry into [$SqlInstanceAsDataDestination].[$DbaDatabase].[dbo].[instance_details].."
        Invoke-DbaQuery -SqlInstance $SqlInstanceAsDataDestination -Database $DbaDatabase -Query $sqlAddInstanceHostMapping -SqlCredential $SqlCredential -EnableException | ft -AutoSize
    }

    # Populate $InventoryServer
    if($InventoryServer -ne $SqlInstanceToBaseline) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Adding entry into [$InventoryServer].[$InventoryDatabase].[dbo].[instance_details].."
        Invoke-DbaQuery -SqlInstance $InventoryServer -Database $InventoryDatabase -Query $sqlAddInstanceHostMapping -SqlCredential $SqlCredential -EnableException | ft -AutoSize
    }

    if($isExpressEdition -or (-not [String]::IsNullOrEmpty($RetentionDays)) ) 
    {
        if($isExpressEdition -and ([String]::IsNullOrEmpty($RetentionDays) -or $RetentionDays -gt 7) ) {
            $RetentionDays = 7
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Since Express Edition, setting retention to $RetentionDays days.." | Write-Host -ForegroundColor Cyan
        }
        else {
            if([String]::IsNullOrEmpty($RetentionDays) -or $RetentionDays -eq 0) {
                $RetentionDays = 14
            }
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Setting retention to $RetentionDays days.." | Write-Host -ForegroundColor Cyan
        }
        
        # Update retention only when table is recently added. For already existing tables, retention should be modified manually
        $sqlSetPurgeThreshold = @"
update dbo.purge_table set retention_days = $RetentionDays 
where retention_days > $RetentionDays
and created_date >= DATEADD(hour,-2,getdate())
"@
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$sqlSetPurgeThreshold => `n`n`t$sqlSetPurgeThreshold"
        Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -Query $sqlSetPurgeThreshold -SqlCredential $SqlCredential -EnableException
    }
}


# 3__XEventSession
$stepName = '3__XEventSession'
if( ($stepName -in $Steps2Execute) -and ($MajorVersion -ge 11) ) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$XEventSessionFilePath = '$XEventSessionFilePath'"

    $dbaDatabasePathParent = Split-Path $dbaDatabasePath -Parent
    if($dbaDatabasePathParent.Length -eq 3) {
        $xEventTargetPathDirectory = "${dbaDatabasePathParent}xevents"
    }
    else {
        $xEventTargetPathDirectoryParent = Split-Path $dbaDatabasePathParent -Parent
        if($xEventTargetPathDirectoryParent.Length -eq 3) {
            $xEventTargetPathDirectory = "$(Split-Path $dbaDatabasePathParent -Parent)xevents"
        }
        else {
            $xEventTargetPathDirectory = "$($xEventTargetPathDirectoryParent)\xevents"
        }
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
    if([String]::IsNullOrEmpty($FirstResponderKitZipFile)) {
        Install-DbaFirstResponderKit -SqlInstance $SqlInstanceToBaseline -Database master -EnableException -SqlCredential $SqlCredential -Verbose:$false -Debug:$false | Format-Table -AutoSize
    }
    else {
        Install-DbaFirstResponderKit -SqlInstance $SqlInstanceToBaseline -Database master -LocalFile $FirstResponderKitZipFile -EnableException -SqlCredential $SqlCredential -Verbose:$false -Debug:$false | Format-Table -AutoSize
    }
}


# 5__DarlingDataObjects
$stepName = '5__DarlingDataObjects'
if($stepName -in $Steps2Execute) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating DarlingData Objects in [master] database.."
    if([String]::IsNullOrEmpty($DarlingDataZipFile)) {
        Install-DbaDarlingData -SqlInstance $SqlInstanceToBaseline -Database master -SqlCredential $SqlCredential -EnableException | Format-Table -AutoSize
    }
    else {
        Install-DbaDarlingData -SqlInstance $SqlInstanceToBaseline -Database master -LocalFile $DarlingDataZipFile -SqlCredential $SqlCredential -EnableException | Format-Table -AutoSize
    }
}


# 6__sp_WhatIsRunning
$stepName = '6__sp_WhatIsRunning'
if($stepName -in $Steps2Execute) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$WhatIsRunningFilePath = '$WhatIsRunningFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating sp_WhatIsRunning procedure in [$DbaDatabase] database.."
    if($MajorVersion -ge 11) {
        Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -File $WhatIsRunningFilePath -SqlCredential $SqlCredential -EnableException | Format-Table -AutoSize
    }
    else {
        $sqlWhatIsRunning = [System.IO.File]::ReadAllText($WhatIsRunningFilePath)        
        $sqlWhatIsRunning = $sqlWhatIsRunning.Replace('open_transaction_count = s.open_transaction_count', "open_transaction_count = 0")
        $sqlWhatIsRunning = $sqlWhatIsRunning.Replace('s.database_id', "null")

        Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -Query $sqlWhatIsRunning -SqlCredential $SqlCredential -EnableException
    }
}


# 7__usp_GetAllServerInfo
$stepName = '7__usp_GetAllServerInfo'
if($stepName -in $Steps2Execute -and $SqlInstanceToBaseline -eq $InventoryServer) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$GetAllServerInfoFilePath = '$GetAllServerInfoFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating usp_GetAllServerInfo procedure in [$DbaDatabase] database.."
    if([String]::IsNullOrEmpty($SqlCredential)) {
        #Invoke-Sqlcmd -ServerInstance $InventoryServer -Database $InventoryDatabase -InputFile $GetAllServerInfoFilePath
        Invoke-DbaQuery -SqlInstance $InventoryServer -Database $InventoryDatabase -File $GetAllServerInfoFilePath
    }
    else {
        #Invoke-Sqlcmd -ServerInstance $InventoryServer -Database $InventoryDatabase -InputFile $GetAllServerInfoFilePath -Credential $SqlCredential
        Invoke-DbaQuery -SqlInstance $InventoryServer -Database $InventoryDatabase -File $GetAllServerInfoFilePath -SqlCredential $SqlCredential
    }
    #Invoke-DbaQuery -SqlInstance $InventoryServer -Database $DbaDatabase -File $GetAllServerInfoFilePath -EnableException
}


# 8__CopyDbaToolsModule2Host
$stepName = '8__CopyDbaToolsModule2Host'
if($stepName -in $Steps2Execute) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$DbaToolsFolderPath = '$DbaToolsFolderPath'"
    
    # Copy dbatools on HostName provided
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Finding valid PSModule path on [$HostName].."
    $remoteModulePath = Invoke-Command -Session $ssn4PerfmonSetup -ScriptBlock {
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
    
    if( (Invoke-Command -Session $ssn4PerfmonSetup -ScriptBlock {Test-Path $Using:dbatoolsRemotePath}) ) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "'$dbatoolsRemotePath' already exists on host [$HostName]."
    }
    else {
        Copy-Item $DbaToolsFolderPath -Destination $dbatoolsRemotePath -ToSession $ssn4PerfmonSetup -Recurse
    }

    # Copy dbatools folder on Jobs Server Host
    if( ($SqlInstanceToBaseline -ne $SqlInstanceForPowershellJobs) -and ($ssn4PerfmonSetup -ne $ssnJobServer) )
    {
        "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Finding valid PSModule path on [$($ssnJobServer.ComputerName)].."
        $remoteModulePath = Invoke-Command -Session $ssnJobServer -ScriptBlock {
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
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Copy dbatools module from '$DbaToolsFolderPath' to host [$($ssnJobServer.ComputerName)] on '$dbatoolsRemotePath'.."
    
        if( (Invoke-Command -Session $ssnJobServer -ScriptBlock {Test-Path $Using:dbatoolsRemotePath}) ) {
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "'$dbatoolsRemotePath' already exists on host [$($ssnJobServer.ComputerName)]."
        }
        else {
            Copy-Item $DbaToolsFolderPath -Destination $dbatoolsRemotePath -ToSession $ssnJobServer -Recurse
        }
    }
}


# 9__CopyPerfmonFolder2Host
$stepName = '9__CopyPerfmonFolder2Host'
if($stepName -in $Steps2Execute) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$psScriptPath = '$psScriptPath'"
    
    # Copy SQLMonitor folder on HostName provided
    if( (Invoke-Command -Session $ssn4PerfmonSetup -ScriptBlock {Test-Path $Using:RemoteSQLMonitorPath}) ) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Sync '$RemoteSQLMonitorPath' on [$HostName] from local copy '$psScriptPath'.."
        Copy-Item "$psScriptPath\*" -Destination "$RemoteSQLMonitorPath" -ToSession $ssn4PerfmonSetup -Exclude "*.blg" -Recurse -Force
    }else {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Copy '$psScriptPath' to '$RemoteSQLMonitorPath' on [$HostName].."
        Copy-Item $psScriptPath -Destination $RemoteSQLMonitorPath -ToSession $ssn4PerfmonSetup -Exclude "*.blg" -Recurse -Force
    }

    # Copy SQLMonitor folder on Jobs Server Host
    if( ($SqlInstanceToBaseline -ne $SqlInstanceForPowershellJobs) -and ($ssn4PerfmonSetup -ne $ssnJobServer) )
    {
        if( (Invoke-Command -Session $ssn4PerfmonSetup -ScriptBlock {Test-Path $Using:RemoteSQLMonitorPath}) ) {
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Sync '$RemoteSQLMonitorPath' on [$HostName] from local copy '$psScriptPath'.."
            Copy-Item "$psScriptPath\*" -Destination "$RemoteSQLMonitorPath" -ToSession $ssn4PerfmonSetup -Exclude "*.blg" -Recurse -Force
        }else {
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Copy '$psScriptPath' to '$RemoteSQLMonitorPath' on [$HostName].."
            Copy-Item $psScriptPath -Destination $RemoteSQLMonitorPath -ToSession $ssn4PerfmonSetup -Exclude "*.blg" -Recurse -Force
        }
    }
}


# 10__SetupPerfmonDataCollector
$stepName = '10__SetupPerfmonDataCollector'
if($stepName -in $Steps2Execute) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Setup Data Collector set 'DBA' on host '$HostName'.."
    Invoke-Command -Session $ssn4PerfmonSetup -ScriptBlock {
        # Set execution policy
        Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy Unrestricted -Force 
        & "$Using:RemoteSQLMonitorPath\perfmon-collector-logman.ps1" -TemplatePath "$Using:RemoteSQLMonitorPath\DBA_PerfMon_All_Counters_Template.xml" -ReSetupCollector $true
    }
}

# If non-domain server, then added HostName in credential name
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Add hostname in Credential name if non-domain server.."
if(-not [String]::IsNullOrEmpty($WindowsCredential))
{
    if( $domain -in @('WORKGROUP','WORKGROUP.com') -and (-not $WindowsCredential.UserName.Contains('\')) ) {
        $credentialName = "$HostName\$($WindowsCredential.UserName)"
    }
    else {
        $credentialName = $WindowsCredential.UserName
    }
    $credentialPassword = $WindowsCredential.Password
}

# 11__CreateCredentialProxy. Create Credential & Proxy on SQL Server. If Instance being baselined is same as data collector job owner
$stepName = '11__CreateCredentialProxy'
if( $requireProxy -and ($stepName -in $Steps2Execute) ) 
{
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."

    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Create new SQL Credential [$credentialName] on [$SqlInstanceForPowershellJobs].."
    $dbaCredential = @()
    $dbaCredential += Get-DbaCredential -SqlInstance $SqlInstanceForPowershellJobs -Name $credentialName -SqlCredential $SqlCredential -EnableException
    if($dbaCredential.Count -eq 0) {
        New-DbaCredential -SqlInstance $SqlInstanceForPowershellJobs -Identity $credentialName -SecurePassword $credentialPassword -SqlCredential $SqlCredential -EnableException
    } else {
        "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "SQL Credential [$credentialName] already exists on [$SqlInstanceForPowershellJobs].."
    }
    $dbaAgentProxy = @()
    $dbaAgentProxy += Get-DbaAgentProxy -SqlInstance $SqlInstanceForPowershellJobs -Proxy $credentialName -SqlCredential $SqlCredential -EnableException
    if($dbaAgentProxy.Count -eq 0) {
        New-DbaAgentProxy -SqlInstance $SqlInstanceForPowershellJobs -Name $credentialName -ProxyCredential $credentialName -SubSystem CmdExec, PowerShell -SqlCredential $SqlCredential -EnableException
    } else {
        "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "SQL Agent Proxy [$credentialName] already exists on [$SqlInstanceForPowershellJobs].."
    }
}


# 12__CreateJobCollectDiskSpace
$stepName = '12__CreateJobCollectDiskSpace'
if($stepName -in $Steps2Execute) 
{
    $jobName = '(dba) Collect-DiskSpace'
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$CollectDiskSpaceJobFilePath = '$CollectDiskSpaceJobFilePath'"
    
    Write-Debug "Debug $stepName"

    # Append HostName if Job Server is different    
    $jobNameNew = $jobName
    if( ($SqlInstanceToBaseline -ne $SqlInstanceForPowershellJobs) -or ($HostName -ne $jobServerDbServiceInfo.host_name) ) {
        $jobNameNew = "$jobName - $HostName"
    }    

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [$jobNameNew] on [$SqlInstanceForPowershellJobs].."
    $sqlCreateJobCollectDiskSpace = [System.IO.File]::ReadAllText($CollectDiskSpaceJobFilePath).Replace('-SqlInstance localhost', "-SqlInstance `"$SqlInstanceAsDataDestination`"")
    $sqlCreateJobCollectDiskSpace = $sqlCreateJobCollectDiskSpace.Replace('-Database DBA', "-Database `"$DbaDatabase`"")
    $sqlCreateJobCollectDiskSpace = $sqlCreateJobCollectDiskSpace.Replace('-HostName localhost', "-HostName `"$HostName`"")
    if($jobNameNew -ne $jobName) {
        $sqlCreateJobCollectDiskSpace = $sqlCreateJobCollectDiskSpace.Replace($jobName, $jobNameNew)
    }

    if($RemoteSQLMonitorPath -ne 'C:\SQLMonitor') {
        $sqlCreateJobCollectDiskSpace = $sqlCreateJobCollectDiskSpace.Replace('C:\SQLMonitor', $RemoteSQLMonitorPath)
    }
    if($DropCreatePowerShellJobs) {
        $tsqlSSMSValidation = "and APP_NAME() = 'Microsoft SQL Server Management Studio - Query'"
        $sqlCreateJobCollectDiskSpace = $sqlCreateJobCollectDiskSpace.Replace($tsqlSSMSValidation, "--$tsqlSSMSValidation")
    }
    Invoke-DbaQuery -SqlInstance $SqlInstanceForPowershellJobs -Database msdb -Query $sqlCreateJobCollectDiskSpace -SqlCredential $SqlCredential -EnableException

    if($requireProxy) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Update job [$jobNameNew] to run under proxy [$credentialName].."
        $sqlUpdateJob = "EXEC msdb.dbo.sp_update_jobstep @job_name=N'$jobNameNew', @step_id=1 ,@proxy_name=N'$credentialName';"
        Invoke-DbaQuery -SqlInstance $SqlInstanceForPowershellJobs -Database msdb -Query $sqlUpdateJob -SqlCredential $SqlCredential -EnableException
    }
    $sqlStartJob = "EXEC msdb.dbo.sp_start_job @job_name=N'$jobNameNew';"
    Invoke-DbaQuery -SqlInstance $SqlInstanceForPowershellJobs -Database msdb -Query $sqlStartJob -SqlCredential $SqlCredential -EnableException
}


# 13__CreateJobCollectOSProcesses
$stepName = '13__CreateJobCollectOSProcesses'
if($stepName -in $Steps2Execute) 
{
    $jobName = '(dba) Collect-OSProcesses'
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$CollectOSProcessesJobFilePath = '$CollectOSProcessesJobFilePath'"

    # Append HostName if Job Server is different    
    $jobNameNew = $jobName
    if( ($SqlInstanceToBaseline -ne $SqlInstanceForPowershellJobs) -or ($HostName -ne $jobServerDbServiceInfo.host_name) ) {
        $jobNameNew = "$jobName - $HostName"
    }   

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [$jobNameNew] on [$SqlInstanceForPowershellJobs].."
    $sqlCreateJobCollectOSProcesses = [System.IO.File]::ReadAllText($CollectOSProcessesJobFilePath).Replace('-SqlInstance localhost', "-SqlInstance `"$SqlInstanceAsDataDestination`"")
    $sqlCreateJobCollectOSProcesses = $sqlCreateJobCollectOSProcesses.Replace('-Database DBA', "-Database `"$DbaDatabase`"")
    $sqlCreateJobCollectOSProcesses = $sqlCreateJobCollectOSProcesses.Replace('-HostName localhost', "-HostName `"$HostName`"")
    if($jobNameNew -ne $jobName) {
        $sqlCreateJobCollectOSProcesses = $sqlCreateJobCollectOSProcesses.Replace($jobName, $jobNameNew)
    }

    if($RemoteSQLMonitorPath -ne 'C:\SQLMonitor') {
        $sqlCreateJobCollectOSProcesses = $sqlCreateJobCollectOSProcesses.Replace('C:\SQLMonitor', $RemoteSQLMonitorPath)
    }
    if($DropCreatePowerShellJobs) {
        $tsqlSSMSValidation = "and APP_NAME() = 'Microsoft SQL Server Management Studio - Query'"
        $sqlCreateJobCollectOSProcesses = $sqlCreateJobCollectOSProcesses.Replace($tsqlSSMSValidation, "--$tsqlSSMSValidation")
    }
    Invoke-DbaQuery -SqlInstance $SqlInstanceForPowershellJobs -Database msdb -Query $sqlCreateJobCollectOSProcesses -SqlCredential $SqlCredential -EnableException

    if($requireProxy) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Update job [$jobNameNew] to run under proxy [$credentialName].."
        $sqlUpdateJob = "EXEC msdb.dbo.sp_update_jobstep @job_name=N'$jobNameNew', @step_id=1 ,@proxy_name=N'$credentialName';"
        Invoke-DbaQuery -SqlInstance $SqlInstanceForPowershellJobs -Database msdb -Query $sqlUpdateJob -SqlCredential $SqlCredential -EnableException
    }
    $sqlStartJob = "EXEC msdb.dbo.sp_start_job @job_name=N'$jobNameNew';"
    Invoke-DbaQuery -SqlInstance $SqlInstanceForPowershellJobs -Database msdb -Query $sqlStartJob -SqlCredential $SqlCredential -EnableException
}


# 14__CreateJobCollectPerfmonData
$stepName = '14__CreateJobCollectPerfmonData'
if($stepName -in $Steps2Execute) 
{
    $jobName = '(dba) Collect-PerfmonData'
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$CollectPerfmonDataJobFilePath = '$CollectPerfmonDataJobFilePath'"

    # Append HostName if Job Server is different    
    $jobNameNew = $jobName
    if( ($SqlInstanceToBaseline -ne $SqlInstanceForPowershellJobs) -or ($HostName -ne $jobServerDbServiceInfo.host_name) ) {
        $jobNameNew = "$jobName - $HostName"
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [$jobNameNew] on [$SqlInstanceForPowershellJobs].."
    $sqlCreateJobCollectPerfmonData = [System.IO.File]::ReadAllText($CollectPerfmonDataJobFilePath).Replace('-SqlInstance localhost', "-SqlInstance `"$SqlInstanceAsDataDestination`"")
    $sqlCreateJobCollectPerfmonData = $sqlCreateJobCollectPerfmonData.Replace('-Database DBA', "-Database `"$DbaDatabase`"")
    $sqlCreateJobCollectPerfmonData = $sqlCreateJobCollectPerfmonData.Replace('-HostName localhost', "-HostName `"$HostName`"")
    if($jobNameNew -ne $jobName) {
        $sqlCreateJobCollectPerfmonData = $sqlCreateJobCollectPerfmonData.Replace($jobName, $jobNameNew)
    }
    
    if($RemoteSQLMonitorPath -ne 'C:\SQLMonitor') {
        $sqlCreateJobCollectPerfmonData = $sqlCreateJobCollectPerfmonData.Replace('C:\SQLMonitor', $RemoteSQLMonitorPath)
    }
    if($DropCreatePowerShellJobs) {
        $tsqlSSMSValidation = "and APP_NAME() = 'Microsoft SQL Server Management Studio - Query'"
        $sqlCreateJobCollectPerfmonData = $sqlCreateJobCollectPerfmonData.Replace($tsqlSSMSValidation, "--$tsqlSSMSValidation")
    }
    Invoke-DbaQuery -SqlInstance $SqlInstanceForPowershellJobs -Database msdb -Query $sqlCreateJobCollectPerfmonData -SqlCredential $SqlCredential -EnableException

    if($requireProxy) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Update job [$jobNameNew] to run under proxy [$credentialName].."
        $sqlUpdateJob = "EXEC msdb.dbo.sp_update_jobstep @job_name=N'$jobNameNew', @step_id=1 ,@proxy_name=N'$credentialName';"
        Invoke-DbaQuery -SqlInstance $SqlInstanceForPowershellJobs -Database msdb -Query $sqlUpdateJob -SqlCredential $SqlCredential -EnableException
    }
    $sqlStartJob = "EXEC msdb.dbo.sp_start_job @job_name=N'$jobNameNew';"
    Invoke-DbaQuery -SqlInstance $SqlInstanceForPowershellJobs -Database msdb -Query $sqlStartJob -SqlCredential $SqlCredential -EnableException
}


# 15__CreateJobCollectWaitStats
$stepName = '15__CreateJobCollectWaitStats'
if($stepName -in $Steps2Execute) 
{
    $jobName = '(dba) Collect-WaitStats'
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$CollectWaitStatsJobFilePath = '$CollectWaitStatsJobFilePath'"

    # Append HostName if Job Server is different    
    $jobNameNew = $jobName
    if($SqlInstanceToBaseline -ne $SqlInstanceForTsqlJobs) {
        $jobNameNew = "$jobName - $SqlInstanceToBaseline"
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [$jobNameNew] on [$SqlInstanceForTsqlJobs].."
    $sqlCreateJobCollectWaitStats = [System.IO.File]::ReadAllText($CollectWaitStatsJobFilePath)
    $sqlCreateJobCollectWaitStats = $sqlCreateJobCollectWaitStats.Replace('-S localhost', "-S `"$SqlInstanceToBaseline`"")
    $sqlCreateJobCollectWaitStats = $sqlCreateJobCollectWaitStats.Replace('-d DBA', "-d `"$DbaDatabase`"")
    $sqlCreateJobCollectWaitStats = $sqlCreateJobCollectWaitStats.Replace("''some_dba_mail_id@gmail.com''", "''$($DbaGroupMailId -join ';')'';" )
    if($jobNameNew -ne $jobName) {
        $sqlCreateJobCollectWaitStats = $sqlCreateJobCollectWaitStats.Replace($jobName, $jobNameNew)
    }

    Invoke-DbaQuery -SqlInstance $SqlInstanceForTsqlJobs -Database msdb -Query $sqlCreateJobCollectWaitStats -SqlCredential $SqlCredential -EnableException
}


# 16__CreateJobCollectXEvents
$stepName = '16__CreateJobCollectXEvents'
if($stepName -in $Steps2Execute) 
{
    $jobName = '(dba) Collect-XEvents'
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$CollectXEventsJobFilePath = '$CollectXEventsJobFilePath'"

    # Append HostName if Job Server is different    
    $jobNameNew = $jobName
    if($SqlInstanceToBaseline -ne $SqlInstanceForTsqlJobs) {
        $jobNameNew = "$jobName - $SqlInstanceToBaseline"
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [$jobNameNew] on [$SqlInstanceForTsqlJobs].."
    $sqlCreateJobCollectXEvents = [System.IO.File]::ReadAllText($CollectXEventsJobFilePath)
    $sqlCreateJobCollectXEvents = $sqlCreateJobCollectXEvents.Replace('-S localhost', "-S `"$SqlInstanceToBaseline`"")
    $sqlCreateJobCollectXEvents = $sqlCreateJobCollectXEvents.Replace('-d DBA', "-d `"$DbaDatabase`"")
    if($jobNameNew -ne $jobName) {
        $sqlCreateJobCollectXEvents = $sqlCreateJobCollectXEvents.Replace($jobName, $jobNameNew)
    }

    Invoke-DbaQuery -SqlInstance $SqlInstanceForTsqlJobs -Database msdb -Query $sqlCreateJobCollectXEvents -SqlCredential $SqlCredential -EnableException
}


# 17__CreateJobCollectFileIOStats
$stepName = '17__CreateJobCollectFileIOStats'
if($stepName -in $Steps2Execute) 
{
    $jobName = '(dba) Collect-FileIOStats'
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$CollectFileIOStatsJobFilePath = '$CollectFileIOStatsJobFilePath'"

    # Append HostName if Job Server is different    
    $jobNameNew = $jobName
    if($SqlInstanceToBaseline -ne $SqlInstanceForTsqlJobs) {
        $jobNameNew = "$jobName - $SqlInstanceToBaseline"
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [$jobNameNew] on [$SqlInstanceForTsqlJobs].."
    $sqlCreateJobFileIOStats = [System.IO.File]::ReadAllText($CollectFileIOStatsJobFilePath)
    $sqlCreateJobFileIOStats = $sqlCreateJobFileIOStats.Replace('-S localhost', "-S `"$SqlInstanceToBaseline`"")
    $sqlCreateJobFileIOStats = $sqlCreateJobFileIOStats.Replace('-d DBA', "-d `"$DbaDatabase`"")
    $sqlCreateJobFileIOStats = $sqlCreateJobFileIOStats.Replace("''some_dba_mail_id@gmail.com''", "''$($DbaGroupMailId -join ';')'';" )
    if($jobNameNew -ne $jobName) {
        $sqlCreateJobFileIOStats = $sqlCreateJobFileIOStats.Replace($jobName, $jobNameNew)
    }

    Invoke-DbaQuery -SqlInstance $SqlInstanceForTsqlJobs -Database msdb -Query $sqlCreateJobFileIOStats -SqlCredential $SqlCredential -EnableException
}


# 18__CreateJobPartitionsMaintenance
$stepName = '18__CreateJobPartitionsMaintenance'
if($stepName -in $Steps2Execute -and $IsNonPartitioned -eq $false) 
{
    $jobName = '(dba) Partitions-Maintenance'
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$PartitionsMaintenanceJobFilePath = '$PartitionsMaintenanceJobFilePath'"

    # Append HostName if Job Server is different    
    $jobNameNew = $jobName
    if($SqlInstanceToBaseline -ne $SqlInstanceForTsqlJobs) {
        $jobNameNew = "$jobName - $SqlInstanceToBaseline"
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [$jobNameNew] on [$SqlInstanceForTsqlJobs].."
    $sqlPartitionsMaintenance = [System.IO.File]::ReadAllText($PartitionsMaintenanceJobFilePath)
    $sqlPartitionsMaintenance = $sqlPartitionsMaintenance.Replace('-S localhost', "-S `"$SqlInstanceToBaseline`"")
    $sqlPartitionsMaintenance = $sqlPartitionsMaintenance.Replace('-d DBA', "-d `"$DbaDatabase`"")
    if($jobNameNew -ne $jobName) {
        $sqlPartitionsMaintenance = $sqlPartitionsMaintenance.Replace($jobName, $jobNameNew)
    }
    Invoke-DbaQuery -SqlInstance $SqlInstanceForTsqlJobs -Database msdb -Query $sqlPartitionsMaintenance -SqlCredential $SqlCredential -EnableException
}


# 19__CreateJobPurgeTables
$stepName = '19__CreateJobPurgeTables'
if($stepName -in $Steps2Execute) 
{
    $jobName = '(dba) Purge-Tables'
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$PurgeTablesJobFilePath = '$PurgeTablesJobFilePath'"

    # Append HostName if Job Server is different    
    $jobNameNew = $jobName
    if($SqlInstanceToBaseline -ne $SqlInstanceForTsqlJobs) {
        $jobNameNew = "$jobName - $SqlInstanceToBaseline"
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [$jobNameNew] on [$SqlInstanceForTsqlJobs].."
    $sqlPurgeDbaMetrics = [System.IO.File]::ReadAllText($PurgeTablesJobFilePath)
    $sqlPurgeDbaMetrics = $sqlPurgeDbaMetrics.Replace('-S localhost', "-S `"$SqlInstanceToBaseline`"")
    $sqlPurgeDbaMetrics = $sqlPurgeDbaMetrics.Replace('-d DBA', "-d `"$DbaDatabase`"")
    if($jobNameNew -ne $jobName) {
        $sqlPurgeDbaMetrics = $sqlPurgeDbaMetrics.Replace($jobName, $jobNameNew)
    }

    Invoke-DbaQuery -SqlInstance $SqlInstanceForTsqlJobs -Database msdb -Query $sqlPurgeDbaMetrics -SqlCredential $SqlCredential -EnableException
}


# 20__CreateJobRemoveXEventFiles
$stepName = '20__CreateJobRemoveXEventFiles'
if($stepName -in $Steps2Execute) 
{
    $jobName = '(dba) Remove-XEventFiles'
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$RemoveXEventFilesJobFilePath = '$RemoveXEventFilesJobFilePath'"

    # Append HostName if Job Server is different    
    $jobNameNew = $jobName
    if( ($SqlInstanceToBaseline -ne $SqlInstanceForPowershellJobs) ) {
        $jobNameNew = "$jobName - $SqlInstanceToBaseline"
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [$jobNameNew] on [$SqlInstanceForPowershellJobs].."
    $sqlCreateJobRemoveXEventFiles = [System.IO.File]::ReadAllText($RemoveXEventFilesJobFilePath)
    $sqlCreateJobRemoveXEventFiles = $sqlCreateJobRemoveXEventFiles.Replace('-SqlInstance localhost', "-SqlInstance `"$SqlInstanceToBaseline`"")
    $sqlCreateJobRemoveXEventFiles = $sqlCreateJobRemoveXEventFiles.Replace('-Database DBA', "-Database `"$DbaDatabase`"")
    if($jobNameNew -ne $jobName) {
        $sqlCreateJobRemoveXEventFiles = $sqlCreateJobRemoveXEventFiles.Replace($jobName, $jobNameNew)
    }

    if($RemoteSQLMonitorPath -ne 'C:\SQLMonitor') {
        $sqlCreateJobRemoveXEventFiles = $sqlCreateJobRemoveXEventFiles.Replace('C:\SQLMonitor', $RemoteSQLMonitorPath)
    }
    if($DropCreatePowerShellJobs) {
        $tsqlSSMSValidation = "and APP_NAME() = 'Microsoft SQL Server Management Studio - Query'"
        $sqlCreateJobRemoveXEventFiles = $sqlCreateJobRemoveXEventFiles.Replace($tsqlSSMSValidation, "--$tsqlSSMSValidation")
    }
    Invoke-DbaQuery -SqlInstance $SqlInstanceForPowershellJobs -Database msdb -Query $sqlCreateJobRemoveXEventFiles -SqlCredential $SqlCredential -EnableException

    if($requireProxy) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Update job [$jobNameNew] to run under proxy [$credentialName].."
        $sqlUpdateJob = "EXEC msdb.dbo.sp_update_jobstep @job_name=N'$jobNameNew', @step_id=1 ,@proxy_name=N'$credentialName';"
        Invoke-DbaQuery -SqlInstance $SqlInstanceForPowershellJobs -Database msdb -Query $sqlUpdateJob -SqlCredential $SqlCredential -EnableException
    }
    $sqlStartJob = "EXEC msdb.dbo.sp_start_job @job_name=N'$jobNameNew';"
    Invoke-DbaQuery -SqlInstance $SqlInstanceForPowershellJobs -Database msdb -Query $sqlStartJob -SqlCredential $SqlCredential -EnableException
}


# 21__CreateJobRunWhoIsActive
$stepName = '21__CreateJobRunWhoIsActive'
if($stepName -in $Steps2Execute) 
{
    $jobName = '(dba) Run-WhoIsActive'
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$RunWhoIsActiveJobFilePath = '$RunWhoIsActiveJobFilePath'"

    # Append HostName if Job Server is different    
    $jobNameNew = $jobName
    if($SqlInstanceToBaseline -ne $SqlInstanceForTsqlJobs) {
        $jobNameNew = "$jobName - $SqlInstanceToBaseline"
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [$jobNameNew] on [$SqlInstanceForTsqlJobs].."
    $sqlRunWhoIsActive = [System.IO.File]::ReadAllText($RunWhoIsActiveJobFilePath)
    $sqlRunWhoIsActive = $sqlRunWhoIsActive.Replace('-S localhost', "-S `"$SqlInstanceToBaseline`"")
    $sqlRunWhoIsActive = $sqlRunWhoIsActive.Replace('-d DBA', "-d `"$DbaDatabase`"")
    $sqlRunWhoIsActive = $sqlRunWhoIsActive.Replace("''some_dba_mail_id@gmail.com''", "''$($DbaGroupMailId -join ';')''" )
    if($jobNameNew -ne $jobName) {
        $sqlRunWhoIsActive = $sqlRunWhoIsActive.Replace($jobName, $jobNameNew)
    }
    
    Invoke-DbaQuery -SqlInstance $SqlInstanceForTsqlJobs -Database msdb -Query $sqlRunWhoIsActive -SqlCredential $SqlCredential -EnableException
}


# 22__CreateJobRunBlitzIndex
$stepName = '22__CreateJobRunBlitzIndex'
if($stepName -in $Steps2Execute) 
{
    $jobName = '(dba) Run-BlitzIndex'
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$RunBlitzIndexJobFilePath = '$RunBlitzIndexJobFilePath'"

    # Append HostName if Job Server is different    
    $jobNameNew = $jobName
    if($SqlInstanceToBaseline -ne $SqlInstanceForTsqlJobs) {
        $jobNameNew = "$jobName - $SqlInstanceToBaseline"
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [$jobNameNew] on [$SqlInstanceForTsqlJobs].."
    $sqlRunBlitzIndexJob = [System.IO.File]::ReadAllText($RunBlitzIndexJobFilePath)
    $sqlRunBlitzIndexJob = $sqlRunBlitzIndexJob.Replace('-S localhost', "-S `"$SqlInstanceToBaseline`"")
    $sqlRunBlitzIndexJob = $sqlRunBlitzIndexJob.Replace('-d DBA', "-d `"$DbaDatabase`"")
    $sqlRunBlitzIndexJob = $sqlRunBlitzIndexJob.Replace("''DBA''", "''$DbaDatabase''" )
    $sqlRunBlitzIndexJob = $sqlRunBlitzIndexJob.Replace("'DBA'", "'$DbaDatabase'" )
    $sqlRunBlitzIndexJob = $sqlRunBlitzIndexJob.Replace("''some_dba_mail_id@gmail.com''", "''$($DbaGroupMailId -join ';')'';" )
    if($jobNameNew -ne $jobName) {
        $sqlRunBlitzIndexJob = $sqlRunBlitzIndexJob.Replace($jobName, $jobNameNew)
    }

    Invoke-DbaQuery -SqlInstance $SqlInstanceForTsqlJobs -Database msdb -Query $sqlRunBlitzIndexJob -SqlCredential $SqlCredential -EnableException
}


# 23__CreateJobRunBlitzIndexWeekly
$stepName = '23__CreateJobRunBlitzIndexWeekly'
if($stepName -in $Steps2Execute) 
{
    $jobName = '(dba) Run-BlitzIndex - Weekly'
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$RunBlitzIndexWeeklyJobFilePath = '$RunBlitzIndexWeeklyJobFilePath'"

    # Append HostName if Job Server is different    
    $jobNameNew = $jobName
    if($SqlInstanceToBaseline -ne $SqlInstanceForTsqlJobs) {
        $jobNameNew = "$jobName - $SqlInstanceToBaseline"
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [$jobNameNew] on [$SqlInstanceForTsqlJobs].."
    $sqlRunBlitzIndexWeeklyJob = [System.IO.File]::ReadAllText($RunBlitzIndexWeeklyJobFilePath)
    $sqlRunBlitzIndexWeeklyJob = $sqlRunBlitzIndexWeeklyJob.Replace('-S localhost', "-S `"$SqlInstanceToBaseline`"")
    $sqlRunBlitzIndexWeeklyJob = $sqlRunBlitzIndexWeeklyJob.Replace('-S "localhost"', "-S `"$SqlInstanceToBaseline`"")
    $sqlRunBlitzIndexWeeklyJob = $sqlRunBlitzIndexWeeklyJob.Replace('-d DBA', "-d `"$DbaDatabase`"")
    $sqlRunBlitzIndexWeeklyJob = $sqlRunBlitzIndexWeeklyJob.Replace('-d "DBA"', "-d `"$DbaDatabase`"")
    $sqlRunBlitzIndexWeeklyJob = $sqlRunBlitzIndexWeeklyJob.Replace("''DBA''", "''$DbaDatabase''" )
    $sqlRunBlitzIndexWeeklyJob = $sqlRunBlitzIndexWeeklyJob.Replace("'DBA'", "'$DbaDatabase'" )
    $sqlRunBlitzIndexWeeklyJob = $sqlRunBlitzIndexWeeklyJob.Replace("''some_dba_mail_id@gmail.com''", "''$($DbaGroupMailId -join ';')'';" )
    if($jobNameNew -ne $jobName) {
        $sqlRunBlitzIndexWeeklyJob = $sqlRunBlitzIndexWeeklyJob.Replace($jobName, $jobNameNew)
    }

    Invoke-DbaQuery -SqlInstance $SqlInstanceForTsqlJobs -Database msdb -Query $sqlRunBlitzIndexWeeklyJob -SqlCredential $SqlCredential -EnableException
}


# 24__CreateJobUpdateSqlServerVersions
$stepName = '24__CreateJobUpdateSqlServerVersions'
if($stepName -in $Steps2Execute -and $SqlInstanceToBaseline -eq $InventoryServer) 
{
    $jobName = '(dba) Update-SqlServerVersions'
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$UpdateSqlServerVersionsJobFilePath = '$UpdateSqlServerVersionsJobFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [$jobName] on [$SqlInstanceToBaseline].."
    $sqlUpdateSqlServerVersions = [System.IO.File]::ReadAllText($UpdateSqlServerVersionsJobFilePath).Replace('-SqlInstance localhost', "-SqlInstance `"$SqlInstanceToBaseline`"")

    if($RemoteSQLMonitorPath -ne 'C:\SQLMonitor') {
        $sqlUpdateSqlServerVersions = $sqlUpdateSqlServerVersions.Replace('C:\SQLMonitor', $RemoteSQLMonitorPath)
    }
    if($DropCreatePowerShellJobs) {
        $tsqlSSMSValidation = "and APP_NAME() = 'Microsoft SQL Server Management Studio - Query'"
        $sqlUpdateSqlServerVersions = $sqlUpdateSqlServerVersions.Replace($tsqlSSMSValidation, "--$tsqlSSMSValidation")
    }
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database msdb -Query $sqlUpdateSqlServerVersions -SqlCredential $SqlCredential -EnableException

    if($requireProxy) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Update job [$jobName] to run under proxy [$credentialName].."
        $sqlUpdateJob = "EXEC msdb.dbo.sp_update_jobstep @job_name=N'$jobName', @step_id=1 ,@proxy_name=N'$credentialName';"
        Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database msdb -Query $sqlUpdateJob -SqlCredential $SqlCredential -EnableException
    }
    $sqlStartJob = "EXEC msdb.dbo.sp_start_job @job_name=N'$jobName';"
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database msdb -Query $sqlStartJob -SqlCredential $SqlCredential -EnableException
}


# CheckInstanceAvailabilityFilePath
# 25__CreateJobCheckInstanceAvailability
$stepName = '25__CreateJobCheckInstanceAvailability'
if($stepName -in $Steps2Execute -and $SqlInstanceToBaseline -eq $InventoryServer) 
{
    $jobName = '(dba) Check-InstanceAvailability'
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$CheckInstanceAvailabilityJobFilePath = '$CheckInstanceAvailabilityJobFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [$jobName] on [$SqlInstanceToBaseline].."
    $sqlGetInstanceAvailability = [System.IO.File]::ReadAllText($CheckInstanceAvailabilityJobFilePath)
    $sqlGetInstanceAvailability = $sqlGetInstanceAvailability.Replace('-InventoryServer localhost', "-InventoryServer `"$SqlInstanceToBaseline`"")
    $sqlGetInstanceAvailability = $sqlGetInstanceAvailability.Replace('-InventoryDatabase DBA', "-InventoryDatabase `"$InventoryDatabase`"")

    if($RemoteSQLMonitorPath -ne 'C:\SQLMonitor') {
        $sqlGetInstanceAvailability = $sqlGetInstanceAvailability.Replace('C:\SQLMonitor', $RemoteSQLMonitorPath)
    }
    if($DropCreatePowerShellJobs) {
        $tsqlSSMSValidation = "and APP_NAME() = 'Microsoft SQL Server Management Studio - Query'"
        $sqlGetInstanceAvailability = $sqlGetInstanceAvailability.Replace($tsqlSSMSValidation, "--$tsqlSSMSValidation")
    }
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database msdb -Query $sqlGetInstanceAvailability -SqlCredential $SqlCredential -EnableException

    if($requireProxy) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Update job [$jobName] to run under proxy [$credentialName].."
        $sqlUpdateJob = "EXEC msdb.dbo.sp_update_jobstep @job_name=N'$jobName', @step_id=1 ,@proxy_name=N'$credentialName';"
        Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database msdb -Query $sqlUpdateJob -SqlCredential $SqlCredential -EnableException
    }
    $sqlStartJob = "EXEC msdb.dbo.sp_start_job @job_name=N'$jobName';"
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database msdb -Query $sqlStartJob -SqlCredential $SqlCredential -EnableException
}


# 26__CreateJobGetAllServerInfo
$stepName = '26__CreateJobGetAllServerInfo'
if($stepName -in $Steps2Execute -and $SqlInstanceToBaseline -eq $InventoryServer) 
{
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$GetAllServerInfoJobFilePath = '$GetAllServerInfoJobFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [(dba) Get-AllServerInfo] on [$InventoryServer].."
    $sqlGetAllServerInfoJobFileText = [System.IO.File]::ReadAllText($GetAllServerInfoJobFilePath)
    $sqlGetAllServerInfoJobFileText = $sqlGetAllServerInfoJobFileText.Replace("@database_name=N'DBA'", "@database_name=N'$InventoryDatabase'")

    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database msdb -Query $sqlGetAllServerInfoJobFileText -SqlCredential $SqlCredential -EnableException
}


# 27__WhoIsActivePartition
$stepName = '27__WhoIsActivePartition'
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

    if($whoIsActiveExists.Count -eq 0) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Table [dbo].[WhoIsActive] does not exist." | Write-Host -ForegroundColor Red
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Kindly ensure job [(dba) Run-WhoIsActive] is running successfully." | Write-Host -ForegroundColor Red
        
        "STOP here, and fix above issue." | Write-Error
    }
    else {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Seems table exists now. Convert [dbo].[WhoIsActive] into partitioned table.."
        Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -Query $sqlPartitionWhoIsActive -SqlCredential $SqlCredential -EnableException
    }
}


# 28__BlitzIndexPartition
$stepName = '28__BlitzIndexPartition'
if($stepName -in $Steps2Execute -and $IsNonPartitioned -eq $false) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$BlitzIndexPartitionFilePath = '$BlitzIndexPartitionFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "ALTER [dbo].[BlitzIndex] table to partitioned table on [$SqlInstanceToBaseline].."
    $sqlPartitionBlitzIndex = [System.IO.File]::ReadAllText($BlitzIndexPartitionFilePath).Replace("[DBA]", "[$DbaDatabase]")
    
    $BlitzIndexExists = @()
    $loopStartTime = Get-Date
    $sleepDurationSeconds = 30
    $loopTotalDurationThresholdSeconds = 300    
    
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Check for existance of table [dbo].[BlitzIndex] on [$SqlInstanceToBaseline].."
    while ($BlitzIndexExists.Count -eq 0 -and $( (New-TimeSpan $loopStartTime $(Get-Date)).TotalSeconds -le $loopTotalDurationThresholdSeconds ) )
    {
        $BlitzIndexExists += Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -SqlCredential $SqlCredential `
                                    -Query "if OBJECT_ID('dbo.BlitzIndex') is not null select OBJECT_ID('dbo.BlitzIndex') as BlitzIndexObjectID" -EnableException

        if($BlitzIndexExists.Count -eq 0) {
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Wait for $sleepDurationSeconds seconds as table dbo.BlitzIndex still does not exist.."
            Start-Sleep -Seconds $sleepDurationSeconds
        }
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Seems table exists now. Convert [dbo].[BlitzIndex] into partitioned table.."
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -Query $sqlPartitionBlitzIndex -SqlCredential $SqlCredential -EnableException
}


# 29__EnablePageCompression
$stepName = '29__EnablePageCompression'
if( ($stepName -in $Steps2Execute) -and ($SkipPageCompression -eq $false) -and $IsCompressionSupported) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Execute procedure [usp_enable_page_compression] on [$SqlInstanceToBaseline].."
    $sqlExecuteUspEnablePageCompression = "exec dbo.usp_enable_page_compression;"
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -Query $sqlExecuteUspEnablePageCompression -SqlCredential $SqlCredential -EnableException
}


# 30__GrafanaLogin
$stepName = '30__GrafanaLogin'
if($stepName -in $Steps2Execute) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$GrafanaLoginFilePath = '$GrafanaLoginFilePath'"
    #"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating All Objects in [$DbaDatabase] database.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Create [grafana] login & user with permissions on objects.."
    $sqlGrafanaLogin = [System.IO.File]::ReadAllText($GrafanaLoginFilePath).Replace("[DBA]", "[$DbaDatabase]")
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database master -Query $sqlGrafanaLogin -SqlCredential $SqlCredential -EnableException
}


# 31__LinkedServerOnInventory
$stepName = '31__LinkedServerOnInventory'
if($stepName -in $Steps2Execute -and $SqlInstanceToBaseline -ne $InventoryServer) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$LinkedServerOnInventoryFilePath = '$LinkedServerOnInventoryFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating linked server for [$SqlInstanceToBaseline] on [$InventoryServer].."
    $sqlLinkedServerOnInventory = [System.IO.File]::ReadAllText($LinkedServerOnInventoryFilePath).Replace("'YourSqlInstanceNameHere'", "'$SqlInstanceToBaseline'")
    $sqlLinkedServerOnInventory = $sqlLinkedServerOnInventory.Replace("@catalog=N'DBA'", "@catalog=N'$DbaDatabase'")
    
    $dbaLinkedServer = @()
    $dbaLinkedServer += Get-DbaLinkedServer -SqlInstance $InventoryServer -LinkedServer $SqlInstanceToBaseline -SqlCredential $SqlCredential
    if($dbaLinkedServer.Count -eq 0) {
        Invoke-DbaQuery -SqlInstance $InventoryServer -Database master -Query $sqlLinkedServerOnInventory -SqlCredential $SqlCredential -EnableException
    } else {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Linked server for [$SqlInstanceToBaseline] on [$InventoryServer] already exists.."
    }
}


# 32__LinkedServerForDataDestinationInstance
$stepName = '32__LinkedServerForDataDestinationInstance'
if( ($stepName -in $Steps2Execute) -and ($SqlInstanceToBaseline -ne $SqlInstanceAsDataDestination) )
{
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$LinkedServerOnInventoryFilePath = '$LinkedServerOnInventoryFilePath'"

    $sqlLinkedServerForDataDestinationInstance = [System.IO.File]::ReadAllText($LinkedServerOnInventoryFilePath)
    $sqlLinkedServerForDataDestinationInstance = $sqlLinkedServerForDataDestinationInstance.Replace("'YourSqlInstanceNameHere'", "'$SqlInstanceAsDataDestination'")
    $sqlLinkedServerForDataDestinationInstance = $sqlLinkedServerForDataDestinationInstance.Replace("@catalog=N'DBA'", "@catalog=N'$DbaDatabase'")
    
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Checking if linked server already exists.."
    $dbaLinkedServer = @()
    $dbaLinkedServer += Get-DbaLinkedServer -SqlInstance $SqlInstanceToBaseline -SqlCredential $SqlCredential -LinkedServer $SqlInstanceAsDataDestination -EnableException
    if($dbaLinkedServer.Count -eq 0) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating linked server for [$SqlInstanceAsDataDestination] on [$SqlInstanceToBaseline].."
        Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database master -Query $sqlLinkedServerForDataDestinationInstance -SqlCredential $SqlCredential -EnableException
    } else {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Linked server named [$SqlInstanceAsDataDestination] already exists on [$SqlInstanceToBaseline]." | Write-Host -ForegroundColor Red
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Kindly validate if linked server is able to access data of [$SqlInstanceAsDataDestination].[$DbaDatabase] database." | Write-Host -ForegroundColor Red
        "STOP and check above error message" | Write-Error
    }
}


# 33__AlterViewsForDataDestinationInstance
$stepName = '33__AlterViewsForDataDestinationInstance'
if( ($stepName -in $Steps2Execute) -and ($SqlInstanceToBaseline -ne $SqlInstanceAsDataDestination) )
{
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."

    # Alter dbo.vw_performance_counters
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Alter view [dbo].[vw_performance_counters].."
    $sqlAlterViewPerformanceCounters = @"
alter view dbo.vw_performance_counters
as
with cte_counters_local as (select collection_time_utc, host_name, object, counter, value, instance from dbo.performance_counters)
,cte_counters_datasource as (select collection_time_utc, host_name, object, counter, value, instance from [$SqlInstanceAsDataDestination].[$DbaDatabase].dbo.performance_counters)

select collection_time_utc, host_name, object, counter, value, instance from cte_counters_local
union all
select collection_time_utc, host_name, object, counter, value, instance from cte_counters_datasource
"@
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -Query $sqlAlterViewPerformanceCounters -SqlCredential $SqlCredential -EnableException


    # Alter dbo.vw_os_task_list
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Alter view [dbo].[vw_os_task_list].."
    $sqlAlterViewOsTaskList = @"
alter view dbo.vw_os_task_list
as
with cte_os_tasks_local as (select [collection_time_utc], [host_name], [task_name], [pid], [session_name], [memory_kb], [status], [user_name], [cpu_time], [cpu_time_seconds], [window_title] from dbo.os_task_list)
,cte_os_tasks_datasource as (select [collection_time_utc], [host_name], [task_name], [pid], [session_name], [memory_kb], [status], [user_name], [cpu_time], [cpu_time_seconds], [window_title] from [$SqlInstanceAsDataDestination].[$DbaDatabase].dbo.os_task_list)

select [collection_time_utc], [host_name], [task_name], [pid], [session_name], [memory_kb], [status], [user_name], [cpu_time], [cpu_time_seconds], [window_title] from cte_os_tasks_local
union all
select [collection_time_utc], [host_name], [task_name], [pid], [session_name], [memory_kb], [status], [user_name], [cpu_time], [cpu_time_seconds], [window_title] from cte_os_tasks_datasource;
"@
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -Query $sqlAlterViewOsTaskList -SqlCredential $SqlCredential -EnableException


    # Alter dbo.vw_disk_space
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Alter view [dbo].[vw_disk_space].."
    $sqlAlterViewDiskSpace = @"
alter view dbo.vw_disk_space
as
with cte_disk_space_local as (select collection_time_utc, host_name, disk_volume, label, capacity_mb, free_mb, block_size, filesystem from dbo.disk_space)
,cte_disk_space_datasource as (select collection_time_utc, host_name, disk_volume, label, capacity_mb, free_mb, block_size, filesystem from [$SqlInstanceAsDataDestination].[$DbaDatabase].dbo.disk_space)

select collection_time_utc, host_name, disk_volume, label, capacity_mb, free_mb, block_size, filesystem from cte_disk_space_local
union all
select collection_time_utc, host_name, disk_volume, label, capacity_mb, free_mb, block_size, filesystem from cte_disk_space_datasource
go
"@
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -Query $sqlAlterViewDiskSpace -SqlCredential $SqlCredential -EnableException
}


# Execute PostQuery
if(-not [String]::IsNullOrEmpty($PostQuery)) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Executing PostQuery on [$SqlInstanceToBaseline].." | Write-Host -ForegroundColor Cyan
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -Query $PostQuery -SqlCredential $SqlCredential -EnableException
}


# Update Version No
if( $true )
{
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Update SQLMonitor Version Number.."

    $sqlUpdateSQLMonitorVersion = @"
update dbo.instance_details set [sqlmonitor_version] = '$sqlmonitorVersion'
where sql_instance = '$SqlInstanceToBaseline'
and host_name = '$HostName'
"@
    # Update dbo.instance_details on SqlInstanceToBaseline
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Update SQLMonitor version on [$SqlInstanceToBaseline].."
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -Query $sqlUpdateSQLMonitorVersion -SqlCredential $SqlCredential -EnableException

    # Update dbo.instance_details on SqlInstanceAsDataDestination
    if($SqlInstanceAsDataDestination -ne $SqlInstanceToBaseline) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Update SQLMonitor version on [$SqlInstanceAsDataDestination].."
        Invoke-DbaQuery -SqlInstance $SqlInstanceAsDataDestination -Database $DbaDatabase -Query $sqlUpdateSQLMonitorVersion -SqlCredential $SqlCredential -EnableException
    }

    # Update dbo.instance_details on InventoryServer
    if($InventoryServer -ne $SqlInstanceToBaseline) {        
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Update SQLMonitor version on [$InventoryServer].."
        Invoke-DbaQuery -SqlInstance $InventoryServer -Database $InventoryDatabase -Query $sqlUpdateSQLMonitorVersion -SqlCredential $SqlCredential -EnableException
    }
}


"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Clearing old PSSessions.."
Get-PSSession | Remove-PSSession

"`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Baselining of [$SqlInstanceToBaseline] completed."

$timeTaken = New-TimeSpan -Start $startTime -End $(Get-Date)
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Execution completed in $($timeTaken.TotalSeconds) seconds."



<#
    .SYNOPSIS
    Baselines the SQL Server instance by creating all required objects, Perfmon data collector, and required SQL Agent jobs. Adds linked server on inventory instance.
    .DESCRIPTION
    This function accepts various parameters and perform baselining of the SQLInstance with creation of required tables, views, procedures, jobs, perfmon data collector, and linked server.
    .PARAMETER SqlInstanceToBaseline
    Name/IP of SQL Instance that has to be baselined. Instances should be capable of connecting from remove machine SSMS using this name/ip.
    .PARAMETER DbaDatabase
    Name of DBA database on the SQL Instance being baseline, and as well target on [SqlInstanceAsDataDestination].
    .PARAMETER SqlInstanceAsDataDestination
    Name/IP of SQL Instance that would store the data caputured using Perfmon data collection. Generally same as [SqlInstanceToBaseline]. But, this could be different from [SqlInstanceToBaseline] in central repository scenario.
    .PARAMETER SqlInstanceForTsqlJobs
    Name/IP of SQL Instance that could be used to host SQL Agent jobs that call tsql scripts. Generally same as [SqlInstanceToBaseline]. This can be used in case of Express Edition as agent services are not available.
    .PARAMETER SqlInstanceForPowershellJobs
    Name/IP of SQL Instance that could be used to host SQL Agent jobs that call tsql scripts. Generally same as [SqlInstanceToBaseline]. This can be used when [SqlInstanceToBaseline] is Express Edition, or not capable of running PowerShell Jobs successfully due to being old version of powershell, or incapability of install modules like dbatools.
    .PARAMETER InventoryServer
    Name/IP of SQL Instance that would act as inventory server and is the data source on Grafana application. A linked server would be created for [SqlInstanceToBaseline] on this server.
    .PARAMETER InventoryDatabase
    Name of DBA database on the InventoryServer. Default to be same as DbaDatabase.
    .PARAMETER HostName
    Name of server where Perfmon data collection & other OS level settings would be done. For standalone SQL Instances, this is not required as this value can be retrieved from tsql. But for active/passive SQLCluster setup where SQL Cluster instance may have other passive nodes, this value can be explictly passed to setup perfmon collection of other passive hosts.
    .PARAMETER IsNonPartitioned
    Switch to signify if Partitioning of table should NOT be done even if supported.
    .PARAMETER SQLMonitorPath
    Path of SQLMonitor tool parent folder. This is the folder that contains other folders/files like Alerting, Credential-Manager, DDLs, SQLMonitor, Inventory etc.
    .PARAMETER DbaToolsFolderPath
    Local directory path of dbatools powershell module that was downloaded locally from github https://github.com/dataplat/dbatools.
    .PARAMETER FirstResponderKitZipFile
    Specifies the path to a local file to install FRK from. This should be the zip file as distributed by the maintainers. If this parameter is not specified, the latest version will be downloaded and installed from https://github.com/BrentOzarULTD/SQL-Server-First-Responder-Kit
    .PARAMETER DarlingDataZipFile
    Specifies the path to a local file to install from. This should be the zip file as distributed by the maintainers. If this parameter is not specified, the latest version will be downloaded and installed from https://github.com/erikdarlingdata/DarlingData
    .PARAMETER RemoteSQLMonitorPath
    Desired SQLMonitor folder location on [SqlInstanceToBaseline] or [SqlInstanceForDataCollectionJobs]. At this path, folder SQLMonitor\SQLMonitor would be copied. On target instance, all the SQL Agent jobs would call the scripts from this folder.
    .PARAMETER MailProfileFileName
    Script file containing tsql that helps in creating mail profile using GMail. This is NOT executed, but displayed when no default global mail profile is found.
    .PARAMETER WhoIsActiveFileName
    Script file containg tsql that compiles [sp_WhoIsActive] in master database. This is modified version of sp_WhoIsActive that returns JobName instead of JobID in [program_name] column.
    .PARAMETER AllDatabaseObjectsFileName
    Script file containing tsql that creates/populates all required objects like partition function, partition scheme, tables and views in [DbaDatabase].
    .PARAMETER XEventSessionFileName
    Script file containing tsql that creates XEvent session [resource_consumption]. By default, the XEvent target files are placed in a new folder named [xevents] inside parent folder of [DbaDatabase] database files.
    .PARAMETER WhatIsRunningFileName
    Script file containing tsql that compiles [sp_WhatIsRunning] in [DbaDatabase].
    .PARAMETER UspGetAllServerInfoFileName
    Script file containing tsql that compiles [usp_GetAllServerInfo] in [DbaDatabase] on [InventoryServer]. This stored procedure provides basic health metrics for all/specific servers.
    .PARAMETER UspCollectWaitStatsFileName
    Script file containing tsql that compiles [usp_collect_wait_stats] in [DbaDatabase] on [SqlInstanceToBaseline].
    .PARAMETER UspCollectFileIOStatsFileName
    Script file containing tsql that compiles [usp_collect_file_io_stats] in [DbaDatabase] on [SqlInstanceToBaseline].
    .PARAMETER UspCollectXeventsResourceConsumptionFileName
    Script file containing tsql that compiles [usp_collect_xevents_resource_consumption] in [DbaDatabase] on [SqlInstanceToBaseline].
    .PARAMETER UspPartitionMaintenanceFileName 
    Script file containing tsql that compiles [usp_partition_maintenance] in [DbaDatabase] on [SqlInstanceToBaseline].
    .PARAMETER UspPurgeTablesFileName
    Script file containing tsql that compiles [usp_purge_tables] in [DbaDatabase] on [SqlInstanceToBaseline].
    .PARAMETER UspRunWhoIsActiveFileName
    Script file containing tsql that compiles [usp_run_WhoIsActive] in [DbaDatabase] on [SqlInstanceToBaseline].
    .PARAMETER UspActiveRequestsCountFileName
    Script file containing tsql that compiles [usp_active_requests_count] in [DbaDatabase] on [SqlInstanceToBaseline].
    .PARAMETER UspWaitsPerCorePerMinuteFileName
    Script file containing tsql that compiles [usp_waits_per_core_per_minute] in [DbaDatabase] on [SqlInstanceToBaseline].
    .PARAMETER UspEnablePageCompressionFileName
    Script file containing tsql that compiles [usp_enable_page_compression] in [DbaDatabase] on [SqlInstanceToBaseline].
    .PARAMETER WhoIsActivePartitionFileName
    Script file containing tsql that convert dbo.WhoIsActive table into partitioned tables if supported.
    .PARAMETER BlitzIndexPartitionFileName
    Script file containing tsql that convert dbo.BlitzIndex table into partitioned tables if supported.
    .PARAMETER GrafanaLoginFileName
    Script file containing tsql that creates [grafana] login/user on [master] & [DbaDatabase] on [SqlInstanceToBaseline].
    .PARAMETER CheckInstanceAvailabilityFileName
    Script file containing tsql that creates sql agent job [(dba) Check-InstanceAvailability] on Inventory Server which calls powershell script to check if a particular SQL Instance is online or not.
    .PARAMETER CollectDiskSpaceFileName
    Script file containing tsql that creates sql agent job [(dba) Collect-DiskSpace] on server [SqlInstanceForPowerShellJobs] which calls powershell scripts for collecting Disk Space utilization from server [SqlInstanceToBaseline].
    .PARAMETER CollectOSProcessesFileName
    Script file containing tsql that creates sql agent job [(dba) Collect-OSProcesses] on server [SqlInstanceForPowerShellJobs] which calls powershell scripts for collecting OS Processes from server [SqlInstanceToBaseline].
    .PARAMETER CollectPerfmonDataFileName
    Script file containing tsql that creates sql agent job [(dba) Collect-PerfmonData] on server [SqlInstanceForPowerShellJobs] which calls powershell scripts for collecting collecting Perfmon data from server [SqlInstanceToBaseline].
    .PARAMETER CollectWaitStatsFileName
    Script file containing tsql that creates sql agent job [(dba) Collect-WaitStats] on server [SqlInstanceForTsqlJobs] which captures cumulative waits.
    .PARAMETER CollectXEventsJobFileName
    Script file containing tsql that creates sql agent job [(dba) Collect-XEvents] on server [SqlInstanceForTsqlJobs] which reads data from XEvent session [resource_consumption] & pushes it to SQL tables.
    .PARAMETER PartitionsMaintenanceFileName
    Script file containing tsql that creates sql agent job [(dba) Partitions-Maintenance] on server [SqlInstanceForTsqlJobs]. This job adds further partions and purges old partitions from partitioned tables.
    .PARAMETER PurgeTablesFileName
    Script file containing tsql that creates sql agent job [(dba) Purge-Tables] on server [SqlInstanceForTsqlJobs]. This job helps in purging old data from tables. Retention threshold varies table to table.
    .PARAMETER RemoveXEventFilesFileName
    Script file containing tsql that creates sql agent job [(dba) Remove-XEventFiles] on server [SqlInstanceForPowerShellJobs]. This job helps in purging Old XEvent files which are already processed.
    .PARAMETER RunWhoIsActiveFileName
    Script file containing tsql that creates sql agent job [(dba) Run-WhoIsActive] on server [SqlInstanceForTsqlJobs]. This job captures snapshot of server sessions using sp_WhoIsActive.
    .PARAMETER UpdateSqlServerVersionsFileName
    Script file containing tsql that creates sql agent job [(dba) Update-SqlServerVersions] on [InventoryServer] server. This job updates the latest version/service pack details into table master.dbo.SqlServerVersions.
    .PARAMETER LinkedServerOnInventoryFileName
    Script file containing tsql that creates linked server for [SqlInstanceToBaseline] on [InventoryServer] server using [grafana] login.
    .PARAMETER TestWindowsAdminAccessFileName
    Script file containing tsql that creates temporary sql agent job [(dba) Test-WindowsAdminAccess] on server [SqlInstanceToBaseline]. This job helps in finding if sql agent proxy is required for executing powershell script.
    .PARAMETER DbaGroupMailId
    List of DBA/group email ids that should receive job failure alerts.
    .PARAMETER StartAtStep
    Starts the baselining automation on this step. If no value provided, then baselining starts with 1st step.
    .PARAMETER SkipSteps
    List of steps that should be skipped in the baselining automation.
    .PARAMETER OnlySteps
    List of steps that should be the only steps to be executed. This parameter has highest precedence and overrides other settings.
    .PARAMETER StopAtStep
    End the baselining automation on this step. If no value provided, then baselining finishes with last step.
    .PARAMETER SqlCredential
    PowerShell credential object to execute queries any SQL Servers. If no value provided, then connectivity is tried using Windows Integrated Authentication.
    .PARAMETER WindowsCredential
    PowerShell credential object that could be used to perform OS interactives tasks. If no value provided, then connectivity is tried using Windows Integrated Authentication. This is important when [SqlInstanceToBaseline] is not in same domain as current host.
    .PARAMETER RetentionDays 
    No of days as data retention threshold in tables  of SQLMonitor. Data older than this value would be purged daily once.
    .PARAMETER DropCreatePowerShellJobs
    When enabled, drops the existing SQL Agent jobs having CmdExec steps, and creates them from scratch. By default, Jobs running CmdExec step are not dropped if found existing.
    .PARAMETER DropCreateWhoIsActiveTable
    When enabled, drops the existing WhoIsActive table, and creates it from scratch. This might be required in case of change in sp_WhoIsActive features usage.
    .PARAMETER SkipPowerShellJobs
    When enabled, baselining steps involving create of SQL Agent jobs having CmdExec steps are skipped.
    .PARAMETER SkipMultiServerviewsUpgrade
    Default enabled. This skips alter of views like vw_performance_counters, vw_disk_space, vw_os_tasks_list etc which interact with multiple hosts in many cases.
    .PARAMETER SkipTsqlJobs
    When enabled, skips creation of all the SQL Agent jobs that execute tsql stored procedures.
    .PARAMETER SkipRDPSessionSteps
    When enabled, any steps that need OS level interaction is skipped. This includes copy of dbatools powershell module, SQLMonitor folder on remove path, creation of Perfmon Data Collector etc.
    .PARAMETER SkipWindowsAdminAccessTest
    When enabled, script does not check if Proxy/Credential is required for running PowerShell jobs.
    .PARAMETER SkipMailProfileCheck 
    When enabled, script does not look for default global mail profile.
    .PARAMETER SkipCollationCheck 
    When enabled, database collations checks are skipped. This means we don't validate if the collation of DBA database  is same as system databases or not.
    .PARAMETER SkipPageCompression
    When enabled, page data compression of SQLMonitor tables is skipped.
    .PARAMETER ConfirmValidationOfMultiInstance
    If required for confirmation from end user in case multiple SQL Instances are found on same host. At max, perfmon data can be pushed to only one SQL Instance.
    .PARAMETER DryRun
    When enabled, only messages are printed, but actual changes are NOT made.
    .PARAMETER PreQuery
    TSQL String that should be executed before actual SQLMonitor scripts are run. This is useful when specific pre-changes are required for SQLMonitor. For example, drop/create few columns etc.
    .PARAMETER PostQuery
    TSQL String that should be executed after actual SQLMonitor scripts are run. This is useful when specific post-changes are required due to environment specific needs.
    .EXAMPLE
$params = @{
    SqlInstanceToBaseline = 'Workstation'
    DbaDatabase = 'DBA'
    DbaToolsFolderPath = 'F:\GitHub\dbatools'
    RemoteSQLMonitorPath = 'C:\SQLMonitor'
    InventoryServer = 'SQLMonitor'
    DbaGroupMailId = 'sqlagentservice@gmail.com'
    #SqlCredential = $saAdmin
    #WindowsCredential = $LabCredential
    #SkipSteps = @("10__SetupPerfmonDataCollector", "12__CreateJobCollectOSProcesses","13__CreateJobCollectPerfmonData")
    #StartAtStep = '30__GrafanaLogin'
    #StopAtStep = '21__WhoIsActivePartition'
    #DropCreatePowerShellJobs = $true
    #DryRun = $false
    #SkipRDPSessionSteps = $true
    #SkipPowerShellJobs = $true
    #SkipAllJobs = $true
}
F:\GitHub\SQLMonitor\SQLMonitor\Install-SQLMonitor.ps1 @Params

Baseline SQLInstance [Workstation] using [DBA] database. Use [SQLMonitor] as Inventory SQLInstance, and alerts should go to 'sqlagentservice@gmail.com'.
    .EXAMPLE
$LabCredential = Get-Credential -UserName 'Lab\SQLServices' -Message 'AD Account'
$saAdmin = Get-Credential -UserName 'sa' -Message 'sa'
#$localAdmin = Get-Credential -UserName 'Administrator' -Message 'Local Admin'

cls
$params = @{
    SqlInstanceToBaseline = 'Workstation'
    DbaDatabase = 'DBA'
    DbaToolsFolderPath = 'F:\GitHub\dbatools'
    RemoteSQLMonitorPath = 'C:\SQLMonitor'
    InventoryServer = 'SQLMonitor'
    DbaGroupMailId = 'sqlagentservice@gmail.com'
    SqlCredential = $saAdmin
    WindowsCredential = $LabCredential
    #SkipSteps = @("10__SetupPerfmonDataCollector", "12__CreateJobCollectOSProcesses","13__CreateJobCollectPerfmonData")
    #StartAtStep = '30__GrafanaLogin'
    #StopAtStep = '21__WhoIsActivePartition'
    #DropCreatePowerShellJobs = $true
    #DryRun = $false
    #SkipRDPSessionSteps = $true
    #SkipPowerShellJobs = $true
    #SkipAllJobs = $true
}
F:\GitHub\SQLMonitor\SQLMonitor\Install-SQLMonitor.ps1 @Params

Baseline SQLInstance [Workstation] using [DBA] database. Use [SQLMonitor] as Inventory SQLInstance. Alerts are sent to 'sqlagentservice@gmail.com'. Using $saAdmin credential while interacting with SQLInstance. Similary, for performing OS interactive task, use $LabCredential.
    .NOTES
Owner Ajay Kumar Dwivedi (ajay.dwivedi2007@gmail.com)
    .LINK
    https://ajaydwivedi.com/github/sqlmonitor
    https://ajaydwivedi.com/youtube/sqlmonitor
    https://ajaydwivedi.com/blog/sqlmonitor    
#>




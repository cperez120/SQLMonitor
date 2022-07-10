[CmdletBinding()]
Param (
    [Parameter(Mandatory=$true)]
    $SqlInstanceToBaseline,

    [Parameter(Mandatory=$false)]
    $DbaDatabase,

    [Parameter(Mandatory=$false)]
    $SqlInstanceAsDataDestination,

    [Parameter(Mandatory=$false)]
    #$SqlInstanceForDataCollectionJobs,
    $SqlInstanceForTsqlJobs,

    [Parameter(Mandatory=$false)]
    $SqlInstanceForPowershellJobs,

    [Parameter(Mandatory=$false)]
    $InventoryServer,

    [Parameter(Mandatory=$false)]
    [String]$HostName,

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
    [String]$UspCollectWaitStatsFileName = "SCH-usp_collect_wait_stats.sql",

    [Parameter(Mandatory=$false)]
    [String]$UspCollectXeventsResourceConsumptionFileName = "SCH-usp_collect_xevents_resource_consumption.sql",

    [Parameter(Mandatory=$false)]
    [String]$UspPartitionMaintenanceFileName = "SCH-usp_partition_maintenance.sql",

    [Parameter(Mandatory=$false)]
    [String]$UspPurgeTablesFileName = "SCH-usp_purge_tables.sql",

    [Parameter(Mandatory=$false)]
    [String]$UspRunWhoIsActiveFileName = "SCH-usp_run_WhoIsActive.sql",

    [Parameter(Mandatory=$false)]
    [String]$WhoIsActivePartitionFileName = "SCH-WhoIsActive-Partitioning.sql",

    [Parameter(Mandatory=$false)]
    [String]$GrafanaLoginFileName = "grafana-login.sql",

    [Parameter(Mandatory=$false)]
    [String]$CollectDiskSpaceFileName = "SCH-Job-[(dba) Collect-DiskSpace].sql",

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
                "10__CopyPerfmonFolder2Host", "11__SetupPerfmonDataCollector", "12__CreateCredentialProxy",
                "13__CreateJobCollectDiskSpace", "14__CreateJobCollectOSProcesses", "15__CreateJobCollectPerfmonData",
                "16__CreateJobCollectWaitStats", "17__CreateJobCollectXEvents", "18__CreateJobPartitionsMaintenance",
                "19__CreateJobPurgeTables", "20__CreateJobRemoveXEventFiles", "21__CreateJobRunWhoIsActive",
                "22__CreateJobUpdateSqlServerVersions", "23__WhoIsActivePartition", "24__GrafanaLogin",
                "25__LinkedServerOnInventory", "26__LinkedServerForDataDestinationInstance")]
    [String]$StartAtStep = "1__sp_WhoIsActive",

    [Parameter(Mandatory=$false)]
    [ValidateSet("1__sp_WhoIsActive", "2__AllDatabaseObjects", "3__XEventSession",
                "4__FirstResponderKitObjects", "5__DarlingDataObjects", "6__OlaHallengrenSolutionObjects",
                "7__sp_WhatIsRunning", "8__usp_GetAllServerInfo", "9__CopyDbaToolsModule2Host",
                "10__CopyPerfmonFolder2Host", "11__SetupPerfmonDataCollector", "12__CreateCredentialProxy",
                "13__CreateJobCollectDiskSpace", "14__CreateJobCollectOSProcesses", "15__CreateJobCollectPerfmonData",
                "16__CreateJobCollectWaitStats", "17__CreateJobCollectXEvents", "18__CreateJobPartitionsMaintenance",
                "19__CreateJobPurgeTables", "20__CreateJobRemoveXEventFiles", "21__CreateJobRunWhoIsActive",
                "22__CreateJobUpdateSqlServerVersions", "23__WhoIsActivePartition", "24__GrafanaLogin",
                "25__LinkedServerOnInventory", "26__LinkedServerForDataDestinationInstance")]
    [String[]]$SkipSteps,

    [Parameter(Mandatory=$false)]
    [ValidateSet("1__sp_WhoIsActive", "2__AllDatabaseObjects", "3__XEventSession",
                "4__FirstResponderKitObjects", "5__DarlingDataObjects", "6__OlaHallengrenSolutionObjects",
                "7__sp_WhatIsRunning", "8__usp_GetAllServerInfo", "9__CopyDbaToolsModule2Host",
                "10__CopyPerfmonFolder2Host", "11__SetupPerfmonDataCollector", "12__CreateCredentialProxy",
                "13__CreateJobCollectDiskSpace", "14__CreateJobCollectOSProcesses", "15__CreateJobCollectPerfmonData",
                "16__CreateJobCollectWaitStats", "17__CreateJobCollectXEvents", "18__CreateJobPartitionsMaintenance",
                "19__CreateJobPurgeTables", "20__CreateJobRemoveXEventFiles", "21__CreateJobRunWhoIsActive",
                "22__CreateJobUpdateSqlServerVersions", "23__WhoIsActivePartition", "24__GrafanaLogin",
                "25__LinkedServerOnInventory", "26__LinkedServerForDataDestinationInstance")]
    [String]$StopAtStep,

    [Parameter(Mandatory=$false)]
    [PSCredential]$SqlCredential,

    [Parameter(Mandatory=$false)]
    [PSCredential]$WindowsCredential,

    [Parameter(Mandatory=$false)]
    [bool]$DropCreatePowerShellJobs = $false,

    [Parameter(Mandatory=$false)]
    [bool]$SkipPowerShellJobs = $false,

    [Parameter(Mandatory=$false)]
    [bool]$SkipTsqlJobs = $false,

    [Parameter(Mandatory=$false)]
    [bool]$SkipRDPSessionSteps = $false,

    [Parameter(Mandatory=$false)]
    [bool]$SkipWindowsAdminAccessTest = $false,

    [Parameter(Mandatory=$false)]
    [bool]$SkipMailProfileCheck = $false,

    [Parameter(Mandatory=$false)]
    [bool]$ConfirmValidationOfMultiInstance = $false,

    [Parameter(Mandatory=$false)]
    [bool]$DryRun = $false
)

# All Steps
$AllSteps = @(  "1__sp_WhoIsActive", "2__AllDatabaseObjects", "3__XEventSession",
                "4__FirstResponderKitObjects", "5__DarlingDataObjects", "6__OlaHallengrenSolutionObjects",
                "7__sp_WhatIsRunning", "8__usp_GetAllServerInfo", "9__CopyDbaToolsModule2Host",
                "10__CopyPerfmonFolder2Host", "11__SetupPerfmonDataCollector", "12__CreateCredentialProxy",
                "13__CreateJobCollectDiskSpace", "14__CreateJobCollectOSProcesses", "15__CreateJobCollectPerfmonData",
                "16__CreateJobCollectWaitStats", "17__CreateJobCollectXEvents", "18__CreateJobPartitionsMaintenance",
                "19__CreateJobPurgeTables", "20__CreateJobRemoveXEventFiles", "21__CreateJobRunWhoIsActive",
                "22__CreateJobUpdateSqlServerVersions", "23__WhoIsActivePartition", "24__GrafanaLogin",
                "25__LinkedServerOnInventory", "26__LinkedServerForDataDestinationInstance")

# TSQL Jobs
$TsqlJobSteps = @(
                "16__CreateJobCollectWaitStats", "17__CreateJobCollectXEvents", "18__CreateJobPartitionsMaintenance",
                "19__CreateJobPurgeTables", "21__CreateJobRunWhoIsActive")

# PowerShell Jobs
$PowerShellJobSteps = @(
                "13__CreateJobCollectDiskSpace", "14__CreateJobCollectOSProcesses", "15__CreateJobCollectPerfmonData",
                "20__CreateJobRemoveXEventFiles", "22__CreateJobUpdateSqlServerVersions")

# RDPSessionSteps
$RDPSessionSteps = @("9__CopyDbaToolsModule2Host", "10__CopyPerfmonFolder2Host", "11__SetupPerfmonDataCollector")


# Add $PowerShellJobSteps to Skip Jobs
if($SkipPowerShellJobs) {
    $SkipSteps = $SkipSteps + $PowerShellJobSteps;
}

# Add $RDPSessionSteps to Skip Jobs
if($SkipRDPSessionSteps) {
    $SkipSteps = $SkipSteps + $RDPSessionSteps;
}

# Add $TsqlJobSteps to Skip Jobs
if($SkipTsqlJobs) {
    $SkipSteps = $SkipSteps + $TsqlJobSteps;
}

# For backward compatability
$SkipAllJobs = $false
if($SkipTsqlJobs -and $SkipPowerShellJobs) {
    $SkipAllJobs = $true
}

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

$mailProfileFilePath = "$ddlPath\$MailProfileFileName"
$WhoIsActiveFilePath = "$ddlPath\$WhoIsActiveFileName"
$AllDatabaseObjectsFilePath = "$ddlPath\$AllDatabaseObjectsFileName"
$XEventSessionFilePath = "$ddlPath\$XEventSessionFileName"
$WhatIsRunningFilePath = "$ddlPath\$WhatIsRunningFileName"
$GetAllServerInfoFilePath = "$ddlPath\$GetAllServerInfoFileName"
$UspCollectWaitStatsFilePath = "$ddlPath\$UspCollectWaitStatsFileName"
$UspCollectXeventsResourceConsumptionFilePath = "$ddlPath\$UspCollectXeventsResourceConsumptionFileName"
$UspPartitionMaintenanceFilePath = "$ddlPath\$UspPartitionMaintenanceFileName"
$UspPurgeTablesFilePath = "$ddlPath\$UspPurgeTablesFileName"
$UspRunWhoIsActiveFilePath = "$ddlPath\$UspRunWhoIsActiveFileName"
$WhoIsActivePartitionFilePath = "$ddlPath\$WhoIsActivePartitionFileName"
$GrafanaLoginFilePath = "$ddlPath\$GrafanaLoginFileName"
$CollectDiskSpaceFilePath = "$ddlPath\$CollectDiskSpaceFileName"
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
#Import-Module SqlServer

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
    $Steps2ExecuteRaw += Compare-Object -ReferenceObject $AllSteps -DifferenceObject $SkipSteps | Select-Object -ExpandProperty InputObject -Unique
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
}

# Extract domain & isClustered property
[bool]$isClustered = $dbServiceInfo.is_clustered
[string]$domain = $dbServiceInfo.domain_reg
if([String]::IsNullOrEmpty($domain)) {
    $domain = $dbServiceInfo.domain+'.com'
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
        $ssnHostName = "$HostName.$domain"
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'WARNING:', "Host [$HostName] not pingable. So trying FQDN form [$ssnHostName].."
    }

    # Try reaching using FQDN, if fails & not a clustered instance, then use SqlInstanceToBaseline itself
    if ( (-not (Test-Connection -ComputerName $ssnHostName -Quiet -Count 1)) -and (-not $isClustered) ) {
        $ssnHostName = $SqlInstanceToBaseline
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'WARNING:', "Host [$ssnHostName] not pingable. Since its not clustered instance, So trying `$SqlInstanceToBaseline parameter value itself.."
    }

    # Try reaching using FQDN, if fails & not a clustered instance, then use SqlInstanceToBaseline itself
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
    if( [String]::IsNullOrEmpty($ssn) -and (-not [String]::IsNullOrEmpty($WindowsCredential)) ) {
        try {
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Attemping PSSession for [$ssnHostName] using provided WindowsCredentials.."
            $ssn4PerfmonSetup = New-PSSession -ComputerName $ssnHostName -Credential $WindowsCredential    
        }
        catch { $errVariables += $_ }

        if( [String]::IsNullOrEmpty($ssn) ) {
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Attemping PSSession for [$ssnHostName] using provided WindowsCredentials with Negotiate attribute.."
            $ssn4PerfmonSetup = New-PSSession -ComputerName $ssnHostName -Credential $WindowsCredential -Authentication Negotiate
        }
    }

    if ( [String]::IsNullOrEmpty($ssn4PerfmonSetup) ) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Provide WindowsCredential for accessing server [$ssnHostName] of domain '$domain'." | Write-Host -ForegroundColor Red
        "STOP here, and fix above issue." | Write-Error -ForegroundColor Red
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
if(-not $SkipPowerShellJobs)
{
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Check for number of SQLServices on [$HostName].."

    $sqlServicesOnHost = @()
    # Localhost system
    if( $HostName -eq $env:COMPUTERNAME ) {
        $sqlServicesOnHost += Get-Service MSSQL* | Where-Object {$_.DisplayName -like 'SQL Server (*)' -and $_.StartType -ne 'Disabled'}
    }
    else {
        $sqlServicesOnHost += Invoke-Command -SessionName $ssn4PerfmonSetup -ScriptBlock { 
                                    Get-Service MSSQL* | Where-Object {$_.DisplayName -like 'SQL Server (*)' -and $_.StartType -ne 'Disabled'} 
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

            "STOP here, and fix above issue." | Write-Error -ForegroundColor Red
        }
        # If destination is provided, then validate if perfmon is not already get collected
        else {
            
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Validate if Perfmon data is not being collected already on [$SqlInstanceAsDataDestination] for same host.."
            $sqlPerfmonRecord = @"
select top 1 'dbo.performance_counters' as QueryData, getutcdate() as current_time_utc, collection_time_utc, pc.host_name
from dbo.performance_counters pc with (nolock)
where pc.collection_time_utc >= DATEADD(minute,-20,GETUTCDATE()) and host_name = '$HostName'
order by pc.collection_time_utc desc
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
        "STOP here, and fix above issue." | Write-Error -ForegroundColor Red
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
if( ($SkipPowerShellJobs -or $SkipAllJobs) -and ($SkipWindowsAdminAccessTest -eq $false) ) { $SkipWindowsAdminAccessTest = $true }
if($SkipWindowsAdminAccessTest -eq $false)
{
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Validate for WindowsCredential if SQL Service Accounts are non-priviledged.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$TestWindowsAdminAccessFilePath = '$TestWindowsAdminAccessFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating & executing job [(dba) Test-WindowsAdminAccess] on [$SqlInstanceForPowershellJobs].."
    $sqlTestWindowsAdminAccessFilePath = [System.IO.File]::ReadAllText($TestWindowsAdminAccessFilePath)
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


# 2__AllDatabaseObjects
$stepName = '2__AllDatabaseObjects'
if($stepName -in $Steps2Execute) 
{
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating All Objects in [$DbaDatabase] database.."

    # Retrieve actual content
    $tempAllDatabaseObjectsFilePath = $AllDatabaseObjectsFilePath

    # Modify content if SQL Server does not support Partitioning
    if($IsNonPartitioned) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Partitioning is not supported on current server."
        $AllDatabaseObjectsFileContent = [System.IO.File]::ReadAllText($AllDatabaseObjectsFilePath)

        $tempAllDatabaseObjectsFileName = "$($AllDatabaseObjectsFileName -replace '.sql','')-NonSupportedVersions.sql"
        $tempAllDatabaseObjectsFilePath = Join-Path $ddlPath $tempAllDatabaseObjectsFileName

        $AllDatabaseObjectsFileContent = $AllDatabaseObjectsFileContent.Replace('declare @is_partitioned bit = 1;', 'declare @is_partitioned bit = 0;')
        $AllDatabaseObjectsFileContent = $AllDatabaseObjectsFileContent.Replace(' on ps_dba', ' --on ps_dba')
        $AllDatabaseObjectsFileContent | Out-File -FilePath $tempAllDatabaseObjectsFilePath
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Non-partitioned code is generated."
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$AllDatabaseObjectsFilePath = '$tempAllDatabaseObjectsFilePath'"
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -File $tempAllDatabaseObjectsFilePath -SqlCredential $SqlCredential -EnableException
    if($IsNonPartitioned) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Remove temp file '$tempAllDatabaseObjectsFilePath'.."
        Remove-Item -Path $tempAllDatabaseObjectsFilePath | Out-Null
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$UspCollectWaitStatsFilePath = '$UspCollectWaitStatsFilePath'"
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -File $UspCollectWaitStatsFilePath -SqlCredential $SqlCredential -EnableException

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$UspCollectXeventsResourceConsumptionFilePath = '$UspCollectXeventsResourceConsumptionFilePath'"
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -File $UspCollectXeventsResourceConsumptionFilePath -SqlCredential $SqlCredential -EnableException

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$UspPartitionMaintenanceFilePath = '$UspPartitionMaintenanceFilePath'"
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -File $UspPartitionMaintenanceFilePath -SqlCredential $SqlCredential -EnableException

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$UspPurgeTablesFilePath = '$UspPurgeTablesFilePath'"
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -File $UspPurgeTablesFilePath -SqlCredential $SqlCredential -EnableException

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$UspRunWhoIsActiveFilePath = '$UspRunWhoIsActiveFilePath'"
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -File $UspRunWhoIsActiveFilePath -SqlCredential $SqlCredential -EnableException

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Adding entry into [$SqlInstanceToBaseline].[$DbaDatabase].[dbo].[instance_hosts].."
    $sqlAddInstanceHost = @"
        if not exists (select * from dbo.instance_hosts where host_name = '$HostName')
        begin
	        insert dbo.instance_hosts ([host_name])
	        select [host_name] = '$HostName';
            
            select 'dbo.instance_hosts' as RunningQuery, * from dbo.instance_hosts
        end
"@
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -Query $sqlAddInstanceHost -SqlCredential $SqlCredential -EnableException | ft -AutoSize
    if($SqlInstanceAsDataDestination -ne $SqlInstanceToBaseline) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Adding entry into [$SqlInstanceAsDataDestination].[$DbaDatabase].[dbo].[instance_hosts].."
        Invoke-DbaQuery -SqlInstance $SqlInstanceAsDataDestination -Database $DbaDatabase -Query $sqlAddInstanceHost -SqlCredential $SqlCredential -EnableException | ft -AutoSize
    }
    if($InventoryServer -ne $SqlInstanceToBaseline) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Adding entry into [$InventoryServer].[$DbaDatabase].[dbo].[instance_hosts].."
        Invoke-DbaQuery -SqlInstance $InventoryServer -Database $DbaDatabase -Query $sqlAddInstanceHost -SqlCredential $SqlCredential -EnableException | ft -AutoSize
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Adding entry into [$SqlInstanceToBaseline].[$DbaDatabase].[dbo].[instance_details].."
    $sqlAddInstanceHostMapping = @"
    if not exists (select * from dbo.instance_details where sql_instance = '$SqlInstanceToBaseline' and [host_name] = '$HostName')
    begin
	    insert dbo.instance_details ( [sql_instance], [host_name], [collector_tsql_jobs_server], [collector_powershell_jobs_server], [data_destination_sql_instance] )
	    select	[sql_instance] = '$SqlInstanceToBaseline',
			    [host_name] = '$Hostname',
			    [collector_tsql_jobs_server] = '$SqlInstanceForTsqlJobs',
                [collector_powershell_jobs_server] = '$SqlInstanceForPowershellJobs',
                [data_destination_sql_instance] = '$SqlInstanceAsDataDestination'

        select 'dbo.instance_details' as RunningQuery, * from dbo.instance_details
    end
"@
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -Query $sqlAddInstanceHostMapping -SqlCredential $SqlCredential -EnableException | ft -AutoSize
    if($SqlInstanceAsDataDestination -ne $SqlInstanceToBaseline) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Adding entry into [$SqlInstanceAsDataDestination].[$DbaDatabase].[dbo].[instance_details].."
        Invoke-DbaQuery -SqlInstance $SqlInstanceAsDataDestination -Database $DbaDatabase -Query $sqlAddInstanceHostMapping -SqlCredential $SqlCredential -EnableException | ft -AutoSize
    }
    if($InventoryServer -ne $SqlInstanceToBaseline) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Adding entry into [$InventoryServer].[$DbaDatabase].[dbo].[instance_details].."
        Invoke-DbaQuery -SqlInstance $InventoryServer -Database $DbaDatabase -Query $sqlAddInstanceHostMapping -SqlCredential $SqlCredential -EnableException | ft -AutoSize
    }


    if($isExpressEdition) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Since instance is Express Edition, change retention to 14 days.." | Write-Host -ForegroundColor Cyan
        Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database $DbaDatabase -Query "update dbo.purge_table set retention_days = 14 where retention_days > 14" -SqlCredential $SqlCredential -EnableException
    }
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

    # If Job Server is different server, then Copy dbatools there also
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


# 10__CopyPerfmonFolder2Host
$stepName = '10__CopyPerfmonFolder2Host'
if($stepName -in $Steps2Execute) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$psScriptPath = '$psScriptPath'"
    
    # Copy SQLMonitor folder on HostName provided
    if( (Invoke-Command -Session $ssn4PerfmonSetup -ScriptBlock {Test-Path $Using:RemoteSQLMonitorPath}) ) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Sync '$RemoteSQLMonitorPath' on [$HostName] from local copy '$psScriptPath'.."
        Copy-Item "$psScriptPath\*" -Destination "$RemoteSQLMonitorPath" -ToSession $ssn4PerfmonSetup -Recurse -Force
    }else {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Copy '$psScriptPath' to '$RemoteSQLMonitorPath' on [$HostName].."
        Copy-Item $psScriptPath -Destination $RemoteSQLMonitorPath -ToSession $ssn4PerfmonSetup -Recurse -Force
    }

    # Copy SQLMonitor folder on Jobs Server Host
    if( ($SqlInstanceToBaseline -ne $SqlInstanceForPowershellJobs) -and ($ssn4PerfmonSetup -ne $ssnJobServer) )
    {
        if( (Invoke-Command -Session $ssn4PerfmonSetup -ScriptBlock {Test-Path $Using:RemoteSQLMonitorPath}) ) {
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Sync '$RemoteSQLMonitorPath' on [$HostName] from local copy '$psScriptPath'.."
            Copy-Item "$psScriptPath\*" -Destination "$RemoteSQLMonitorPath" -ToSession $ssn4PerfmonSetup -Recurse -Force
        }else {
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Copy '$psScriptPath' to '$RemoteSQLMonitorPath' on [$HostName].."
            Copy-Item $psScriptPath -Destination $RemoteSQLMonitorPath -ToSession $ssn4PerfmonSetup -Recurse -Force
        }
    }
}


# 11__SetupPerfmonDataCollector
$stepName = '11__SetupPerfmonDataCollector'
if($stepName -in $Steps2Execute) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Setup Data Collector set 'DBA' on host '$HostName'.."
    Invoke-Command -Session $ssn4PerfmonSetup -ScriptBlock {
        # Set execution policy
        Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy Unrestricted -Force 
        & "$Using:RemoteSQLMonitorPath\perfmon-collector-logman.ps1" -TemplatePath "$Using:RemoteSQLMonitorPath\DBA_PerfMon_All_Counters_Template.xml" -ReSetupCollector $true
    }
}


# 12__CreateCredentialProxy. Create Credential & Proxy on SQL Server. If Instance being baselined is same as data collector job owner
$stepName = '12__CreateCredentialProxy'
if( $requireProxy -and ($stepName -in $Steps2Execute) ) 
{
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    $credentialName = $WindowsCredential.UserName
    $credentialPassword = $WindowsCredential.Password

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


# 13__CreateJobCollectDiskSpace
$stepName = '13__CreateJobCollectDiskSpace'
if($stepName -in $Steps2Execute) 
{
    $jobName = '(dba) Collect-DiskSpace'
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$CollectDiskSpaceFilePath = '$CollectDiskSpaceFilePath'"
    
    # Append HostName if Job Server is different    
    $jobNameNew = $jobName
    if( ($SqlInstanceToBaseline -ne $SqlInstanceForPowershellJobs) -and ($HostName -ne $jobServerDbServiceInfo.host_name) ) {
        $jobNameNew = "$jobName - $HostName"
    }    

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [$jobNameNew] on [$SqlInstanceForPowershellJobs].."
    $sqlCreateJobCollectDiskSpace = [System.IO.File]::ReadAllText($CollectDiskSpaceFilePath).Replace('-SqlInstance localhost', "-SqlInstance `"$SqlInstanceAsDataDestination`"")
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


# 14__CreateJobCollectOSProcesses
$stepName = '14__CreateJobCollectOSProcesses'
if($stepName -in $Steps2Execute) 
{
    $jobName = '(dba) Collect-OSProcesses'
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$CollectOSProcessesFilePath = '$CollectOSProcessesFilePath'"

    # Append HostName if Job Server is different    
    $jobNameNew = $jobName
    if( ($SqlInstanceToBaseline -ne $SqlInstanceForPowershellJobs) -and ($HostName -ne $jobServerDbServiceInfo.host_name) ) {
        $jobNameNew = "$jobName - $HostName"
    }   

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [$jobNameNew] on [$SqlInstanceForPowershellJobs].."
    $sqlCreateJobCollectOSProcesses = [System.IO.File]::ReadAllText($CollectOSProcessesFilePath).Replace('-SqlInstance localhost', "-SqlInstance `"$SqlInstanceAsDataDestination`"")
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


# 15__CreateJobCollectPerfmonData
$stepName = '15__CreateJobCollectPerfmonData'
if($stepName -in $Steps2Execute) 
{
    $jobName = '(dba) Collect-PerfmonData'
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$CollectPerfmonDataFilePath = '$CollectPerfmonDataFilePath'"

    # Append HostName if Job Server is different    
    $jobNameNew = $jobName
    if( ($SqlInstanceToBaseline -ne $SqlInstanceForPowershellJobs) -and ($HostName -ne $jobServerDbServiceInfo.host_name) ) {
        $jobNameNew = "$jobName - $HostName"
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [$jobNameNew] on [$SqlInstanceForPowershellJobs].."
    $sqlCreateJobCollectPerfmonData = [System.IO.File]::ReadAllText($CollectPerfmonDataFilePath).Replace('-SqlInstance localhost', "-SqlInstance `"$SqlInstanceAsDataDestination`"")
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


# 16__CreateJobCollectWaitStats
$stepName = '16__CreateJobCollectWaitStats'
if($stepName -in $Steps2Execute) 
{
    $jobName = '(dba) Collect-WaitStats'
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$CollectWaitStatsFilePath = '$CollectWaitStatsFilePath'"

    # Append HostName if Job Server is different    
    $jobNameNew = $jobName
    if($SqlInstanceToBaseline -ne $SqlInstanceForTsqlJobs) {
        $jobNameNew = "$jobName - $SqlInstanceToBaseline"
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [$jobNameNew] on [$SqlInstanceForTsqlJobs].."
    $sqlCreateJobCollectWaitStats = [System.IO.File]::ReadAllText($CollectWaitStatsFilePath)
    $sqlCreateJobCollectWaitStats = $sqlCreateJobCollectWaitStats.Replace('-S Localhost', "-S `"$SqlInstanceToBaseline`"")
    $sqlCreateJobCollectWaitStats = $sqlCreateJobCollectWaitStats.Replace('-d DBA', "-d `"$DbaDatabase`"")
    $sqlCreateJobCollectWaitStats = $sqlCreateJobCollectWaitStats.Replace("''some_dba_mail_id@gmail.com''", "''$($DbaGroupMailId -join ';')'';" )
    if($jobNameNew -ne $jobName) {
        $sqlCreateJobCollectWaitStats = $sqlCreateJobCollectWaitStats.Replace($jobName, $jobNameNew)
    }

    Invoke-DbaQuery -SqlInstance $SqlInstanceForTsqlJobs -Database msdb -Query $sqlCreateJobCollectWaitStats -SqlCredential $SqlCredential -EnableException
}


# 17__CreateJobCollectXEvents
$stepName = '17__CreateJobCollectXEvents'
if($stepName -in $Steps2Execute) 
{
    $jobName = '(dba) Collect-XEvents'
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$CollectXEventsFilePath = '$CollectXEventsFilePath'"

    # Append HostName if Job Server is different    
    $jobNameNew = $jobName
    if($SqlInstanceToBaseline -ne $SqlInstanceForTsqlJobs) {
        $jobNameNew = "$jobName - $SqlInstanceToBaseline"
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [$jobNameNew] on [$SqlInstanceForTsqlJobs].."
    $sqlCreateJobCollectXEvents = [System.IO.File]::ReadAllText($CollectXEventsFilePath)
    $sqlCreateJobCollectXEvents = $sqlCreateJobCollectXEvents.Replace('-S Localhost', "-S `"$SqlInstanceToBaseline`"")
    $sqlCreateJobCollectXEvents = $sqlCreateJobCollectXEvents.Replace('-d DBA', "-d `"$DbaDatabase`"")
    if($jobNameNew -ne $jobName) {
        $sqlCreateJobCollectXEvents = $sqlCreateJobCollectXEvents.Replace($jobName, $jobNameNew)
    }

    Invoke-DbaQuery -SqlInstance $SqlInstanceForTsqlJobs -Database msdb -Query $sqlCreateJobCollectXEvents -SqlCredential $SqlCredential -EnableException
}


# 18__CreateJobPartitionsMaintenance
$stepName = '18__CreateJobPartitionsMaintenance'
if($stepName -in $Steps2Execute -and $IsNonPartitioned -eq $false) 
{
    $jobName = '(dba) Partitions-Maintenance'
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$PartitionsMaintenanceFilePath = '$PartitionsMaintenanceFilePath'"

    # Append HostName if Job Server is different    
    $jobNameNew = $jobName
    if($SqlInstanceToBaseline -ne $SqlInstanceForTsqlJobs) {
        $jobNameNew = "$jobName - $SqlInstanceToBaseline"
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [$jobNameNew] on [$SqlInstanceForTsqlJobs].."
    $sqlPartitionsMaintenance = [System.IO.File]::ReadAllText($PartitionsMaintenanceFilePath)
    $sqlPartitionsMaintenance = $sqlPartitionsMaintenance.Replace('-S Localhost', "-S `"$SqlInstanceToBaseline`"")
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
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$PurgeTablesFilePath = '$PurgeTablesFilePath'"

    # Append HostName if Job Server is different    
    $jobNameNew = $jobName
    if($SqlInstanceToBaseline -ne $SqlInstanceForTsqlJobs) {
        $jobNameNew = "$jobName - $SqlInstanceToBaseline"
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [$jobNameNew] on [$SqlInstanceForTsqlJobs].."
    $sqlPurgeDbaMetrics = [System.IO.File]::ReadAllText($PurgeTablesFilePath)
    $sqlPurgeDbaMetrics = $sqlPurgeDbaMetrics.Replace('-S Localhost', "-S `"$SqlInstanceToBaseline`"")
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
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$RemoveXEventFilesFilePath = '$RemoveXEventFilesFilePath'"

    # Append HostName if Job Server is different    
    $jobNameNew = $jobName
    if( ($SqlInstanceToBaseline -ne $SqlInstanceForPowershellJobs) ) {
        $jobNameNew = "$jobName - $HostName"
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [$jobNameNew] on [$SqlInstanceForPowershellJobs].."
    $sqlCreateJobRemoveXEventFiles = [System.IO.File]::ReadAllText($RemoveXEventFilesFilePath)
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
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$RunWhoIsActiveFilePath = '$RunWhoIsActiveFilePath'"

    # Append HostName if Job Server is different    
    $jobNameNew = $jobName
    if($SqlInstanceToBaseline -ne $SqlInstanceForTsqlJobs) {
        $jobNameNew = "$jobName - $SqlInstanceToBaseline"
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating job [$jobNameNew] on [$SqlInstanceForTsqlJobs].."
    $sqlRunWhoIsActive = [System.IO.File]::ReadAllText($RunWhoIsActiveFilePath)
    $sqlRunWhoIsActive = $sqlRunWhoIsActive.Replace('-S Localhost', "-S `"$SqlInstanceToBaseline`"")
    $sqlRunWhoIsActive = $sqlRunWhoIsActive.Replace('-d DBA', "-d `"$DbaDatabase`"")
    $sqlRunWhoIsActive = $sqlRunWhoIsActive.Replace("''some_dba_mail_id@gmail.com''", "''$($DbaGroupMailId -join ';')'';" )
    if($jobNameNew -ne $jobName) {
        $sqlRunWhoIsActive = $sqlRunWhoIsActive.Replace($jobName, $jobNameNew)
    }

    Invoke-DbaQuery -SqlInstance $SqlInstanceForTsqlJobs -Database msdb -Query $sqlRunWhoIsActive -SqlCredential $SqlCredential -EnableException
}


# 22__CreateJobUpdateSqlServerVersions
$stepName = '22__CreateJobUpdateSqlServerVersions'
if($stepName -in $Steps2Execute -and $SqlInstanceToBaseline -eq $InventoryServer) 
{
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
        $sqlUpdateJob = "EXEC msdb.dbo.sp_update_jobstep @job_name=N'Update-SqlServerVersions', @step_id=1 ,@proxy_name=N'$credentialName';"
        Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database msdb -Query $sqlUpdateJob -SqlCredential $SqlCredential -EnableException
    }
    $sqlStartJob = "EXEC msdb.dbo.sp_start_job @job_name=N'(dba) Update-SqlServerVersions';"
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database msdb -Query $sqlStartJob -SqlCredential $SqlCredential -EnableException
}


# 23__WhoIsActivePartition
$stepName = '23__WhoIsActivePartition'
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


# 24__GrafanaLogin
$stepName = '24__GrafanaLogin'
if($stepName -in $Steps2Execute) {
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$GrafanaLoginFilePath = '$GrafanaLoginFilePath'"
    #"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating All Objects in [$DbaDatabase] database.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Create [grafana] login & user with permissions on objects.."
    $sqlGrafanaLogin = [System.IO.File]::ReadAllText($GrafanaLoginFilePath).Replace("[DBA]", "[$DbaDatabase]")
    Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database master -Query $sqlGrafanaLogin -SqlCredential $SqlCredential -EnableException
}


# 25__LinkedServerOnInventory
$stepName = '25__LinkedServerOnInventory'
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

# 26__LinkedServerForDataDestinationInstance
$stepName = '26__LinkedServerForDataDestinationInstance'
if( ($stepName -in $Steps2Execute) -and ($SqlInstanceToBaseline -ne $SqlInstanceAsDataDestination) )
{
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$LinkedServerOnInventoryFilePath = '$LinkedServerOnInventoryFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating linked server for [$SqlInstanceAsDataDestination] on [$SqlInstanceToBaseline].."

    $sqlLinkedServerForDataDestinationInstance = [System.IO.File]::ReadAllText($LinkedServerOnInventoryFilePath)
    $sqlLinkedServerForDataDestinationInstance = $sqlLinkedServerForDataDestinationInstance.Replace("'YourSqlInstanceNameHere'", "'$SqlInstanceAsDataDestination'")
    $sqlLinkedServerForDataDestinationInstance = $sqlLinkedServerForDataDestinationInstance.Replace("@catalog=N'DBA'", "@catalog=N'$DbaDatabase'")
    
    $dbaLinkedServer = @()
    $dbaLinkedServer += Get-DbaLinkedServer -SqlInstance $SqlInstanceToBaseline -LinkedServer $SqlInstanceAsDataDestination
    if($dbaLinkedServer.Count -eq 0) {
        Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -Database master -Query $sqlLinkedServerForDataDestinationInstance -SqlCredential $SqlCredential -EnableException
    } else {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Linked server for [$SqlInstanceAsDataDestination] on [$SqlInstanceToBaseline] already exists.."
    }


    # Alter dbo.vw_performance_counters
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Alter view [dbo].[vw_performance_counters].."
    $sqlAlterViewPerformanceCounters = @"
alter view dbo.vw_performance_counters
as
with cte_counters_local as (select collection_time_utc, host_name, path, object, counter, value, instance from dbo.performance_counters)
,cte_counters_datasource as (select collection_time_utc, host_name, path, object, counter, value, instance from [$SqlInstanceAsDataDestination].[$DbaDatabase].dbo.performance_counters)

select collection_time_utc, host_name, path, object, counter, value, instance from cte_counters_local
union all
select collection_time_utc, host_name, path, object, counter, value, instance from cte_counters_datasource
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
    .PARAMETER HostName
    Name of server where Perfmon data collection & other OS level settings would be done. For standalone SQL Instances, this is not required as this value can be retrieved from tsql. But for active/passive SQLCluster setup where SQL Cluster instance may have other passive nodes, this value can be explictly passed to setup perfmon collection of other passive hosts.
    .PARAMETER IsNonPartitioned
    Switch to signify if Partitioning of table should NOT be done even if supported.
    .PARAMETER SQLMonitorPath
    Path of SQLMonitor tool parent folder. This is the folder that contains other folders/files like Alerting, Credential-Manager, DDLs, SQLMonitor, Inventory etc.
    .PARAMETER DbaToolsFolderPath
    Local directory path of dbatools powershell module that was downloaded locally from github https://github.com/dataplat/dbatools.
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
    .PARAMETER GetAllServerInfoFileName
    Script file containing tsql that compiles [usp_GetAllServerInfo] in [DbaDatabase] on [InventoryServer]. This stored procedure provides basic health metrics for all/specific servers.
    .PARAMETER UspCollectWaitStatsFileName
    Script file containing tsql that compiles [usp_collect_wait_stats] in [DbaDatabase] on [SqlInstanceToBaseline].
    .PARAMETER UspCollectXeventsResourceConsumptionFileName
    Script file containing tsql that compiles [usp_collect_xevents_resource_consumption] in [DbaDatabase] on [SqlInstanceToBaseline].
    .PARAMETER UspPartitionMaintenanceFileName 
    Script file containing tsql that compiles [usp_partition_maintenance] in [DbaDatabase] on [SqlInstanceToBaseline].
    .PARAMETER UspPurgeTablesFileName
    Script file containing tsql that compiles [usp_purge_tables] in [DbaDatabase] on [SqlInstanceToBaseline].
    .PARAMETER UspRunWhoIsActiveFileName
    Script file containing tsql that compiles [usp_run_WhoIsActive] in [DbaDatabase] on [SqlInstanceToBaseline].
    .PARAMETER WhoIsActivePartitionFileName
    Script file containing tsql that convert dbo.WhoIsActive table into partitioned tables if supported.
    .PARAMETER GrafanaLoginFileName
    Script file containing tsql that creates [grafana] login/user on [master] & [DbaDatabase] on [SqlInstanceToBaseline].
    .PARAMETER CollectDiskSpaceFileName
    Script file containing tsql that creates sql agent job [(dba) Collect-DiskSpace] on server [SqlInstanceForDataCollectionJobs] which calls powershell scripts for collecting Disk Space utilization from server [SqlInstanceToBaseline].
    .PARAMETER CollectOSProcessesFileName
    Script file containing tsql that creates sql agent job [(dba) Collect-OSProcesses] on server [SqlInstanceForDataCollectionJobs] which calls powershell scripts for collecting OS Processes from server [SqlInstanceToBaseline].
    .PARAMETER CollectPerfmonDataFileName
    Script file containing tsql that creates sql agent job [(dba) Collect-PerfmonData] on server [SqlInstanceForDataCollectionJobs] which calls powershell scripts for collecting collecting Perfmon data from server [SqlInstanceToBaseline].
    .PARAMETER CollectWaitStatsFileName
    Script file containing tsql that creates sql agent job [(dba) Collect-WaitStats] on server [SqlInstanceToBaseline] which captures cumulative waits.
    .PARAMETER CollectXEventsFileName
    Script file containing tsql that creates sql agent job [(dba) Collect-XEvents] on server [SqlInstanceToBaseline] which reads data from XEvent session [resource_consumption] & pushes it to SQL tables.
    .PARAMETER PartitionsMaintenanceFileName
    Script file containing tsql that creates sql agent job [(dba) Partitions-Maintenance] on server [SqlInstanceToBaseline]. This job adds further partions and purges old partitions from partitioned tables.
    .PARAMETER PurgeTablesFileName
    Script file containing tsql that creates sql agent job [(dba) Purge-Tables] on server [SqlInstanceToBaseline]. This job helps in purging old data from tables. Retention threshold varies table to table.
    .PARAMETER RemoveXEventFilesFileName
    Script file containing tsql that creates sql agent job [(dba) Remove-XEventFiles] on server [SqlInstanceToBaseline]. This job helps in purging Old XEvent files which are already processed.
    .PARAMETER RunWhoIsActiveFileName
    Script file containing tsql that creates sql agent job [(dba) Run-WhoIsActive] on server [SqlInstanceToBaseline]. This job captures snapshot of server sessions using sp_WhoIsActive.
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
    .PARAMETER StopAtStep
    End the baselining automation on this step. If no value provided, then baselining finishes with last step.
    .PARAMETER SqlCredential
    PowerShell credential object to execute queries any SQL Servers. If no value provided, then connectivity is tried using Windows Integrated Authentication.
    .PARAMETER WindowsCredential
    PowerShell credential object that could be used to perform OS interactives tasks. If no value provided, then connectivity is tried using Windows Integrated Authentication. This is important when [SqlInstanceToBaseline] is not in same domain as current host.
    .PARAMETER DropCreatePowerShellJobs
    When enabled, drops the existing SQL Agent jobs having CmdExec steps, and creates them from scratch. By default, Jobs running CmdExec step are not dropped if found existing.
    .PARAMETER SkipPowerShellJobs
    When enabled, baselining steps involving create of SQL Agent jobs having CmdExec steps are skipped.
    .PARAMETER SkipTsqlJobs
    When enabled, skips creation of all the SQL Agent jobs that execute tsql stored procedures.
    .PARAMETER SkipRDPSessionSteps
    When enabled, any steps that need OS level interaction is skipped. This includes copy of dbatools powershell module, SQLMonitor folder on remove path, creation of Perfmon Data Collector etc.
    .PARAMETER SkipWindowsAdminAccessTest
    When enabled, script does not check if Proxy/Credential is required for running PowerShell jobs.
    .PARAMETER SkipMailProfileCheck 
    When enabled, script does not look for default global mail profile.
    .PARAMETER ConfirmValidationOfMultiInstance
    If required for confirmation from end user in case multiple SQL Instances are found on same host. At max, perfmon data can be pushed to only one SQL Instance.
    .PARAMETER DryRun
    When enabled, only messages are printed, but actual changes are NOT made.
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
    #SkipSteps = @("11__SetupPerfmonDataCollector", "12__CreateJobCollectOSProcesses","13__CreateJobCollectPerfmonData")
    #StartAtStep = '24__GrafanaLogin'
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
    #SkipSteps = @("11__SetupPerfmonDataCollector", "12__CreateJobCollectOSProcesses","13__CreateJobCollectPerfmonData")
    #StartAtStep = '24__GrafanaLogin'
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
    https://ajaydwivedi.com/docs/sqlmonitor
    https://ajaydwivedi.com/blog/sqlmonitor
    https://ajaydwivedi.com/youtube/sqlmonitor
#>
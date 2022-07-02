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

    [Parameter(Mandatory=$false)]
    [String]$SQLMonitorPathOnRemote,

    [Parameter(Mandatory=$true)]
    [String]$DbaToolsFolderPath,    

    [Parameter(Mandatory=$false)]
    [ValidateSet("1__RemoveJob_CollectDiskSpace", "2__RemoveJob_CollectOSProcesses", "3__RemoveJob_CollectPerfmonData",
                "4__RemoveJob_CollectWaitStats", "5__RemoveJob_CollectXEvents", "6__RemoveJob_PartitionsMaintenance",
                "7__RemoveJob_PurgeTables", "8__RemoveJob_RemoveXEvents", "9__RemoveJob_RunWhoIsActive",
                "10__RemoveJob_UpdateSqlServerVersions", "11__DropProc_UspExtendedResults", "12__DropProc_UspCollectWaitStats",
                "13__DropProc_UspRunWhoIsActive", "14__DropProc_UspCollectXEventsResourceConsumption", "15__DropProc_UspPurgeTables",
                "16__DropProc_SpWhatIsRunning", "17__DropView_VwPerformanceCounters", "18__DropView_VwOsTaskList",
                "19__DropView_VwWaitStatsDeltas", "20__DropXEvent_ResourceConsumption", "21__DropLinkedServer",
                "22__DropLogin_Grafana", "23__DropTable_ResourceConsumption","24__DropTable_ResourceConsumptionProcessedXELFiles",
                "25__DropTable_WhoIsActive_Staging", "26__DropTable_WhoIsActive", "27__DropTable_PerformanceCounters",
                "28__DropTable_PurgeTable", "29__DropTable_PerfmonFiles", "30__DropTable_InstanceHosts", 
                "31__DropTable_OsTaskList", "32__DropTable_BlitzWho", "33__DropTable_BlitzCache",
                "34__DropTable_ConnectionHistory", "35__DropTable_BlitzFirst", "36__DropTable_BlitzFirstFileStats",
                "37__DropTable_InstanceDetails", "38__DropTable_DiskSpace", "39__DropTable_BlitzFirstPerfmonStats",
                "40__DropTable_BlitzFirstWaitStats", "41__DropTable_BlitzFirstWaitStatsCategories", "42__DropTable_WaitStats",
                "43__RemovePerfmonFilesFromDisk", "44__RemoveXEventFilesFromDisk", "45__DropProxy",
                "46__DropCredential")]
    [String]$StartAtStep = "1__RemoveJob_CollectDiskSpace",

    [Parameter(Mandatory=$false)]
    [ValidateSet("1__RemoveJob_CollectDiskSpace", "2__RemoveJob_CollectOSProcesses", "3__RemoveJob_CollectPerfmonData",
                "4__RemoveJob_CollectWaitStats", "5__RemoveJob_CollectXEvents", "6__RemoveJob_PartitionsMaintenance",
                "7__RemoveJob_PurgeTables", "8__RemoveJob_RemoveXEvents", "9__RemoveJob_RunWhoIsActive",
                "10__RemoveJob_UpdateSqlServerVersions", "11__DropProc_UspExtendedResults", "12__DropProc_UspCollectWaitStats",
                "13__DropProc_UspRunWhoIsActive", "14__DropProc_UspCollectXEventsResourceConsumption", "15__DropProc_UspPurgeTables",
                "16__DropProc_SpWhatIsRunning", "17__DropView_VwPerformanceCounters", "18__DropView_VwOsTaskList",
                "19__DropView_VwWaitStatsDeltas", "20__DropXEvent_ResourceConsumption", "21__DropLinkedServer",
                "22__DropLogin_Grafana", "23__DropTable_ResourceConsumption","24__DropTable_ResourceConsumptionProcessedXELFiles",
                "25__DropTable_WhoIsActive_Staging", "26__DropTable_WhoIsActive", "27__DropTable_PerformanceCounters",
                "28__DropTable_PurgeTable", "29__DropTable_PerfmonFiles", "30__DropTable_InstanceHosts", 
                "31__DropTable_OsTaskList", "32__DropTable_BlitzWho", "33__DropTable_BlitzCache",
                "34__DropTable_ConnectionHistory", "35__DropTable_BlitzFirst", "36__DropTable_BlitzFirstFileStats",
                "37__DropTable_InstanceDetails", "38__DropTable_DiskSpace", "39__DropTable_BlitzFirstPerfmonStats",
                "40__DropTable_BlitzFirstWaitStats", "41__DropTable_BlitzFirstWaitStatsCategories", "42__DropTable_WaitStats",
                "43__RemovePerfmonFilesFromDisk", "44__RemoveXEventFilesFromDisk", "45__DropProxy",
                "46__DropCredential")]
    [String[]]$SkipSteps,

    [Parameter(Mandatory=$false)]
    [ValidateSet("1__RemoveJob_CollectDiskSpace", "2__RemoveJob_CollectOSProcesses", "3__RemoveJob_CollectPerfmonData",
                "4__RemoveJob_CollectWaitStats", "5__RemoveJob_CollectXEvents", "6__RemoveJob_PartitionsMaintenance",
                "7__RemoveJob_PurgeTables", "8__RemoveJob_RemoveXEvents", "9__RemoveJob_RunWhoIsActive",
                "10__RemoveJob_UpdateSqlServerVersions", "11__DropProc_UspExtendedResults", "12__DropProc_UspCollectWaitStats",
                "13__DropProc_UspRunWhoIsActive", "14__DropProc_UspCollectXEventsResourceConsumption", "15__DropProc_UspPurgeTables",
                "16__DropProc_SpWhatIsRunning", "17__DropView_VwPerformanceCounters", "18__DropView_VwOsTaskList",
                "19__DropView_VwWaitStatsDeltas", "20__DropXEvent_ResourceConsumption", "21__DropLinkedServer",
                "22__DropLogin_Grafana", "23__DropTable_ResourceConsumption","24__DropTable_ResourceConsumptionProcessedXELFiles",
                "25__DropTable_WhoIsActive_Staging", "26__DropTable_WhoIsActive", "27__DropTable_PerformanceCounters",
                "28__DropTable_PurgeTable", "29__DropTable_PerfmonFiles", "30__DropTable_InstanceHosts", 
                "31__DropTable_OsTaskList", "32__DropTable_BlitzWho", "33__DropTable_BlitzCache",
                "34__DropTable_ConnectionHistory", "35__DropTable_BlitzFirst", "36__DropTable_BlitzFirstFileStats",
                "37__DropTable_InstanceDetails", "38__DropTable_DiskSpace", "39__DropTable_BlitzFirstPerfmonStats",
                "40__DropTable_BlitzFirstWaitStats", "41__DropTable_BlitzFirstWaitStatsCategories", "42__DropTable_WaitStats",
                "43__RemovePerfmonFilesFromDisk", "44__RemoveXEventFilesFromDisk", "45__DropProxy",
                "46__DropCredential")]
    [String]$StopAtStep,

    [Parameter(Mandatory=$false)]
    [bool]$SkipDropTable = $false,

    [Parameter(Mandatory=$false)]
    [bool]$SkipRemoveJob = $false,

    [Parameter(Mandatory=$false)]
    [bool]$SkipDropProcedure = $false,

    [Parameter(Mandatory=$false)]
    [bool]$SkipDropView = $false,

    [Parameter(Mandatory=$false)]
    [PSCredential]$SqlCredential,

    [Parameter(Mandatory=$false)]
    [PSCredential]$WindowsCredential,

    [Parameter(Mandatory=$false)]
    [bool]$WhatIf = $true

)

# All Steps
$AllSteps = @(  "1__RemoveJob_CollectDiskSpace", "2__RemoveJob_CollectOSProcesses", "3__RemoveJob_CollectPerfmonData",
                "4__RemoveJob_CollectWaitStats", "5__RemoveJob_CollectXEvents", "6__RemoveJob_PartitionsMaintenance",
                "7__RemoveJob_PurgeTables", "8__RemoveJob_RemoveXEvents", "9__RemoveJob_RunWhoIsActive",
                "10__RemoveJob_UpdateSqlServerVersions", "11__DropProc_UspExtendedResults", "12__DropProc_UspCollectWaitStats",
                "13__DropProc_UspRunWhoIsActive", "14__DropProc_UspCollectXEventsResourceConsumption", "15__DropProc_UspPurgeTables",
                "16__DropProc_SpWhatIsRunning", "17__DropView_VwPerformanceCounters", "18__DropView_VwOsTaskList",
                "19__DropView_VwWaitStatsDeltas", "20__DropXEvent_ResourceConsumption", "21__DropLinkedServer",
                "22__DropLogin_Grafana", "23__DropTable_ResourceConsumption","24__DropTable_ResourceConsumptionProcessedXELFiles",
                "25__DropTable_WhoIsActive_Staging", "26__DropTable_WhoIsActive", "27__DropTable_PerformanceCounters",
                "28__DropTable_PurgeTable", "29__DropTable_PerfmonFiles", "30__DropTable_InstanceHosts", 
                "31__DropTable_OsTaskList", "32__DropTable_BlitzWho", "33__DropTable_BlitzCache",
                "34__DropTable_ConnectionHistory", "35__DropTable_BlitzFirst", "36__DropTable_BlitzFirstFileStats",
                "37__DropTable_InstanceDetails", "38__DropTable_DiskSpace", "39__DropTable_BlitzFirstPerfmonStats",
                "40__DropTable_BlitzFirstWaitStats", "41__DropTable_BlitzFirstWaitStatsCategories", "42__DropTable_WaitStats",
                "43__RemovePerfmonFilesFromDisk", "44__RemoveXEventFilesFromDisk", "45__DropProxy",
                "46__DropCredential"
                )

cls
$startTime = Get-Date
$ErrorActionPreference = "Stop"

"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'START:', "Working on server [$SqlInstanceToBaseline] with [$DbaDatabase] database.`n" | Write-Host -ForegroundColor Yellow


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

"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$SqlInstanceToBaseline = [$SqlInstanceToBaseline]"
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$SqlInstanceForDataCollectionJobs = [$SqlInstanceForDataCollectionJobs]"
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$SqlInstanceAsDataDestination = [$SqlInstanceAsDataDestination]"

"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$SqlCredential => "
$SqlCredential | ft -AutoSize
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$WindowsCredential => "
$WindowsCredential | ft -AutoSize

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
                            $passThrough = $true;
                            if( -not ($currentStepNumber -ge $StartAtStepNumber -and $currentStepNumber -le $StopAtStepNumber) ) {
                                $passThrough = $false
                            }
                            if( $passThrough -and ($SkipDropTable -and $_ -like '*__DropTable_*') ) {
                                $passThrough = $false
                            }
                            if( $passThrough -and ($SkipRemoveJob -and $_ -like '*__RemoveJob_*') ) {
                                $passThrough = $false
                            }
                            if( $passThrough -and ($SkipDropProcedure -and $_ -like '*__DropProc_*') ) {
                                $passThrough = $false
                            }
                            if( $passThrough -and ($SkipDropView -and $_ -like '*__DropView_*') ) {
                                $passThrough = $false
                            } 
                            if($passThrough) {$_}
                        }
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$StartAtStep -> $StartAtStep.."
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$StopAtStep -> $StopAtStep.."
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Total steps to execute -> $($Steps2Execute.Count)."

if($WhatIf) {
    "`n`n" | Write-Host
    $Steps2Execute
    "`n`n" | Write-Host
}

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


# 1__RemoveJob_CollectDiskSpace
$stepName = '1__RemoveJob_CollectDiskSpace'
if($stepName -in $Steps2Execute) {
    $jobName = '(dba) Collect-DiskSpace'
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Find & remove job '$jobName'.."
    #Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -File $WhoIsActiveFilePath -SqlCredential $SqlCredential -EnableException
}


# 2__RemoveJob_CollectOSProcesses
$stepName = '2__RemoveJob_CollectOSProcesses'
if($stepName -in $Steps2Execute) {
    $jobName = '(dba) Collect-OSProcesses'
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Find & remove job '$jobName'.."
    #Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -File $WhoIsActiveFilePath -SqlCredential $SqlCredential -EnableException
}


# 3__RemoveJob_CollectPerfmonData
$stepName = '3__RemoveJob_CollectPerfmonData'
if($stepName -in $Steps2Execute) {
    $jobName = '(dba) Collect-PerfmonData'
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Find & remove job '$jobName'.."
    #Invoke-DbaQuery -SqlInstance $SqlInstanceToBaseline -File $WhoIsActiveFilePath -SqlCredential $SqlCredential -EnableException
}




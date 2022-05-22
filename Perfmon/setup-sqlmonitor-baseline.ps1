[CmdletBinding()]
Param (
    [Parameter(Mandatory=$false)]
    $SqlInstance = 'Demo\SQL2014',

    [Parameter(Mandatory=$false)]
    $DbaDatabase = 'DBA',

    [Parameter(Mandatory=$false)]
    $InventoryServer = 'SQLMonitor',

    [Switch]$IsNonPartitioned,

    [Parameter(Mandatory=$false)]
    [String]$SQLMonitorPath = "F:\GitHub\SQLMonitor",

    [Parameter(Mandatory=$false)]
    [bool]$WhatIf = $false,

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
    [String]$PurgeDbaMetricsFileName = "SCH-Job-[(dba) Purge-DbaMetrics - Daily].sql",

    [Parameter(Mandatory=$false)]
    [String]$RemoveXEventFilesFileName = "SCH-Job-[(dba) Remove-XEventFiles].sql",

    [Parameter(Mandatory=$false)]
    [String]$RunWhoIsActiveFileName = "SCH-Job-[(dba) Run-WhoIsActive].sql",

    [Parameter(Mandatory=$false)]
    [String]$UpdateSqlServerVersionsFileName = "SCH-Job-[(dba) Update-SqlServerVersions].sql",

    [Parameter(Mandatory=$false)]
    [String]$LinkedServerOnInventoryFileName = "SCH-Linked-Servers-Sample.sql",

    [Parameter(Mandatory=$false)]
    [ValidateSet("1__sp_WhoIsActive", "2__AllDatabaseObjects", "3__XEventSession",
                "4__FirstResponderKitObjects", "5__DarlingDataObjects", "6__OlaHallengrenSolutionObjects",
                "7__sp_WhatIsRunning", "8__usp_GetAllServerInfo", "9__GrafanaLogin", 
                "10__CopyPerfmonFolder2Host", "11__SetupPerfmonDataCollector", "12__CreateJobCollectOSProcesses", 
                "13__CreateJobCollectPerfmonData", "14__CreateJobCollectWaitStats", "15__CreateJobCollectXEvents", 
                "16__CreateJobPartitionsMaintenance", "17__CreateJobPurgeDbaMetrics", "18__CreateJobRemoveXEventFiles", 
                "19__CreateJobRunWhoIsActive", "20__CreateJobUpdateSqlServerVersions", "21__LinkedServerOnInventory", 
                "22__WhoIsActivePartition")]
    [String]$StartAtStep = "1__sp_WhoIsActive",

    [Parameter(Mandatory=$false)]
    [ValidateSet("1__sp_WhoIsActive", "2__AllDatabaseObjects", "3__XEventSession",
                "4__FirstResponderKitObjects", "5__DarlingDataObjects", "6__OlaHallengrenSolutionObjects",
                "7__sp_WhatIsRunning", "8__usp_GetAllServerInfo", "9__GrafanaLogin", 
                "10__CopyPerfmonFolder2Host", "11__SetupPerfmonDataCollector", "12__CreateJobCollectOSProcesses", 
                "13__CreateJobCollectPerfmonData", "14__CreateJobCollectWaitStats", "15__CreateJobCollectXEvents", 
                "16__CreateJobPartitionsMaintenance", "17__CreateJobPurgeDbaMetrics", "18__CreateJobRemoveXEventFiles", 
                "19__CreateJobRunWhoIsActive", "20__CreateJobUpdateSqlServerVersions", "21__LinkedServerOnInventory", 
                "22__WhoIsActivePartition")]
    [String[]]$SkipSteps = @("21__CreateJobUpdateSqlServerVersions","22__LinkedServerOnInventory"),

    [Parameter(Mandatory=$false)]
    [PSCredential]$SqlCredential

)

# All Steps
$AllSteps = @(  "1__sp_WhoIsActive", "2__AllDatabaseObjects", "3__XEventSession",
                "4__FirstResponderKitObjects", "5__DarlingDataObjects", "6__OlaHallengrenSolutionObjects",
                "7__sp_WhatIsRunning", "8__usp_GetAllServerInfo", "9__GrafanaLogin", 
                "10__CopyPerfmonFolder2Host", "11__SetupPerfmonDataCollector", "12__CreateJobCollectOSProcesses", 
                "13__CreateJobCollectPerfmonData", "14__CreateJobCollectWaitStats", "15__CreateJobCollectXEvents", 
                "16__CreateJobPartitionsMaintenance", "17__CreateJobPurgeDbaMetrics", "18__CreateJobRemoveXEventFiles", 
                "19__CreateJobRunWhoIsActive", "20__CreateJobUpdateSqlServerVersions", "21__LinkedServerOnInventory", 
                "22__WhoIsActivePartition")

cls
$startTime = Get-Date
$ErrorActionPreference = "Stop"

"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'START:', "Working on server [$SqlInstance] with [$DbaDatabase] database."

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

# Construct File Path Variables
$ddlPath = Join-Path $SQLMonitorPath "DDLs"
$perfmonPath = Join-Path $SQLMonitorPath "Perfmon"
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
$PurgeDbaMetricsFilePath = "$ddlPath\$PurgeDbaMetricsFileName"
$RemoveXEventFilesFilePath = "$ddlPath\$RemoveXEventFilesFileName"
$RunWhoIsActiveFilePath = "$ddlPath\$RunWhoIsActiveFileName"
$UpdateSqlServerVersionsFilePath = "$ddlPath\$UpdateSqlServerVersionsFileName"
$LinkedServerOnInventoryFilePath = "$ddlPath\$LinkedServerOnInventoryFileName"

"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$ddlPath = '$ddlPath'"
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$perfmonPath = '$perfmonPath'"

"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Import dbatools module.."
Import-Module dbatools

# Compute steps to execute
[int]$StartAtStepNumber = $StartAtStep -replace "__\w+", ''
$Steps2Execute = @()
$Steps2Execute += Compare-Object -ReferenceObject $AllSteps -DifferenceObject $SkipSteps | ForEach-Object { if([int]$($_.InputObject -replace "__\w+", '') -ge $StartAtStepNumber) {$_.InputObject}}


# Get Server Info
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Fetching basic server info.."
$sqlServerInfo = @"
select	default_domain() as [domain],
		[ip] = CONNECTIONPROPERTY('local_net_address'),
		[sql_instance] = serverproperty('MachineName'),
		[server_name] = serverproperty('ServerName'),
		[host_name] = SERVERPROPERTY('ComputerNamePhysicalNetBIOS'),
		[service_name_str] = servicename,
		[service_name] = case when @@servicename = 'MSSQLSERVER' then @@servicename else 'MSSQL$'+@@servicename end,
		[instance_name] = @@servicename,
		service_account,
		SERVERPROPERTY('Edition') AS Edition,
		SERVERPROPERTY('ProductVersion') AS ProductVersion,
		SERVERPROPERTY('ProductLevel') AS ProductLevel
		--,instant_file_initialization_enabled
		--,*
from sys.dm_server_services where servicename like 'SQL Server (%)'
"@
$sqlServerInfo = Invoke-DbaQuery -SqlInstance $SqlInstance -Query $sqlServerInfo -SqlCredential $SqlCredential -EnableException
$sqlServerInfo | Format-Table -AutoSize
if($sqlServerInfo.domain -eq 'WORKGROUP' -and [String]::IsNullOrEmpty($SqlCredential)) {
    "Kindly provide SqlCredentials." | Write-Host -ForegroundColor Red
    Write-Error "Stop here. Fix above issue."
}
if( ($sqlServerInfo.service_account -like 'NT Service*') -and ([String]::IsNullOrEmpty($SqlCredential)) ) {
    "SQL Service account is local account." | Write-Host -ForegroundColor Red
    "Kindly provide SqlCredentials that is admin on OS & SQL Server." | Write-Host -ForegroundColor Red
    Write-Error "Stop here. Fix above issue."
}
$IsNonPartitioned = $false
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
$ssn = New-PSSession -ComputerName $($sqlServerInfo.host_name) -Credential $SqlCredential

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
$mailProfile += Invoke-DbaQuery -SqlInstance $SqlInstance -Database msdb -Query $sqlMailProfile -EnableException -SqlCredential $SqlCredential
if($mailProfile.Count -lt 1) {
    "Kindly create default global mail profile." | Write-Host -ForegroundColor Red
    "Kindly utilize '$mailProfileFilePath." | Write-Host -ForegroundColor Red
    "Opening the file '$mailProfileFilePath' in notepad.." | Write-Host -ForegroundColor Red
    notepad "$mailProfileFilePath"
    Write-Error "Stop here. Fix above issue."
}


# 1__sp_WhoIsActive
$stepName = '1__sp_WhoIsActive'
if($stepName -in $Steps2Execute) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$WhoIsActiveFilePath = '$WhoIsActiveFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating sp_WhoIsActive in [master] database.."
    Invoke-DbaQuery -SqlInstance $SqlInstance -File $WhoIsActiveFilePath -EnableException
}


# 2__AllDatabaseObjects
$stepName = '2__AllDatabaseObjects'
if($stepName -in $Steps2Execute) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating All Objects in [$DbaDatabase] database.."
    if($IsNonPartitioned) {
        $AllDatabaseObjectsFileName = "$($AllDatabaseObjectsFileName -replace '.sql','')-NonSupportedVersions.sql"
        $AllDatabaseObjectsFilePath = Join-Path $ddlPath $AllDatabaseObjectsFileName
    }
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$AllDatabaseObjectsFilePath = '$AllDatabaseObjectsFilePath'"
    Invoke-DbaQuery -SqlInstance $SqlInstance -Database $DbaDatabase -File $AllDatabaseObjectsFilePath -EnableException
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
    $dbaDatabasePath = Invoke-DbaQuery -SqlInstance $SqlInstance -Database master -SqlCredential $SqlCredential -Query $sqlDbaDatabasePath -EnableException | Select-Object -ExpandProperty physical_name
    
    $xEventTargetPathDirectory = Join-Path $(Split-Path (Split-Path $dbaDatabasePath -Parent)) "xevents"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Computed XEvent files directory -> '$xEventTargetPathDirectory'.."
    if(-not (Test-Path $($xEventTargetPathDirectory))) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Create directory '$xEventTargetPathDirectory' for XEvent files.."
        Invoke-DbaQuery -SqlInstance $SqlInstance -Database $DbaDatabase -SqlCredential $SqlCredential -Query "EXEC xp_create_subdir '$xEventTargetPathDirectory'" -EnableException
    }

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Create XEvent session named [resource_consumption].."
    $sqlXEventSession = [System.IO.File]::ReadAllText($XEventSessionFilePath).Replace('E:\Data\xevents', "$xEventTargetPathDirectory")
    Invoke-DbaQuery -SqlInstance $SqlInstance -Database master -Query $sqlXEventSession -SqlCredential $SqlCredential -EnableException | Format-Table -AutoSize
}


# 4__FirstResponderKitObjects
$stepName = '4__FirstResponderKitObjects'
if($stepName -in $Steps2Execute) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating FirstResponderKit Objects in [master] database.."
    Install-DbaFirstResponderKit -SqlInstance $SqlInstance -Database master -EnableException | Format-Table -AutoSize
}


# 5__DarlingDataObjects
$stepName = '5__DarlingDataObjects'
if($stepName -in $Steps2Execute) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating DarlingData Objects in [master] database.."
    Install-DbaDarlingData -SqlInstance $SqlInstance -Database master -EnableException | Format-Table -AutoSize
}


# 6__OlaHallengrenSolutionObjects
$stepName = '6__OlaHallengrenSolutionObjects'
if($stepName -in $Steps2Execute) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating OlaHallengren Solution Objects in [$DbaDatabase] database.."
    Install-DbaMaintenanceSolution -SqlInstance $SqlInstance -Database $DbaDatabase -EnableException -ReplaceExisting | Format-Table -AutoSize
}


# 7__sp_WhatIsRunning
$stepName = '7__sp_WhatIsRunning'
if($stepName -in $Steps2Execute) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$WhatIsRunningFilePath = '$WhatIsRunningFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating sp_WhatIsRunning procedure in [$DbaDatabase] database.."
    Invoke-DbaQuery -SqlInstance $SqlInstance -Database $DbaDatabase -File $WhatIsRunningFilePath -EnableException | Format-Table -AutoSize
}


# 8__usp_GetAllServerInfo
$stepName = '8__usp_GetAllServerInfo'
if($stepName -in $Steps2Execute) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$GetAllServerInfoFilePath = '$GetAllServerInfoFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating usp_GetAllServerInfo procedure in [$DbaDatabase] database.."
    #Invoke-DbaQuery -SqlInstance $SqlInstance -Database $DbaDatabase -File $GetAllServerInfoFilePath -EnableException
    Invoke-Sqlcmd -ServerInstance $SqlInstance -Database $DbaDatabase -InputFile $GetAllServerInfoFilePath
}


# 9__GrafanaLogin
$stepName = '9__GrafanaLogin'
if($stepName -in $Steps2Execute) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$GrafanaLoginFilePath = '$GrafanaLoginFilePath'"
    #"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating All Objects in [$DbaDatabase] database.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Create [grafana] login & user with permissions on objects.."
    $sqlGrafanaLogin = [System.IO.File]::ReadAllText($GrafanaLoginFilePath).Replace('[DBA]', "[$DbaDatabase]")
    Invoke-DbaQuery -SqlInstance $SqlInstance -Database master -Query $sqlGrafanaLogin -SqlCredential $SqlCredential -EnableException
}


# 10__CopyPerfmonFolder2Host
$stepName = '10__CopyPerfmonFolder2Host'
if($stepName -in $Steps2Execute) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$perfmonPath = '$perfmonPath'"
    
    Copy-Item $perfmonPath -Destination "C:\Perfmon" -ToSession $ssn -Recurse
}

return
# 11__SetupPerfmonDataCollector
if('2__AllDatabaseObjects' -in $Steps2Execute) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating All Objects in [$DbaDatabase] database.."
    Install-DbaMaintenanceSolution -SqlInstance $SqlInstance -Database $DbaDatabase -Verbose -EnableException
}


# 12__CreateJobCollectOSProcesses
if('2__AllDatabaseObjects' -in $Steps2Execute) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating All Objects in [$DbaDatabase] database.."
    Install-DbaMaintenanceSolution -SqlInstance $SqlInstance -Database $DbaDatabase -Verbose -EnableException
}


# 13__CreateJobCollectPerfmonData
if('2__AllDatabaseObjects' -in $Steps2Execute) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating All Objects in [$DbaDatabase] database.."
    Install-DbaMaintenanceSolution -SqlInstance $SqlInstance -Database $DbaDatabase -Verbose -EnableException
}


# 14__CreateJobCollectWaitStats
if('2__AllDatabaseObjects' -in $Steps2Execute) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating All Objects in [$DbaDatabase] database.."
    Install-DbaMaintenanceSolution -SqlInstance $SqlInstance -Database $DbaDatabase -Verbose -EnableException
}


# 15__CreateJobCollectXEvents
if('2__AllDatabaseObjects' -in $Steps2Execute) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating All Objects in [$DbaDatabase] database.."
    Install-DbaMaintenanceSolution -SqlInstance $SqlInstance -Database $DbaDatabase -Verbose -EnableException
}


# 16__CreateJobPartitionsMaintenance
if('2__AllDatabaseObjects' -in $Steps2Execute) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating All Objects in [$DbaDatabase] database.."
    Install-DbaMaintenanceSolution -SqlInstance $SqlInstance -Database $DbaDatabase -Verbose -EnableException
}


# 17__CreateJobPurgeDbaMetrics
if('2__AllDatabaseObjects' -in $Steps2Execute) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating All Objects in [$DbaDatabase] database.."
    Install-DbaMaintenanceSolution -SqlInstance $SqlInstance -Database $DbaDatabase -Verbose -EnableException
}


# 18__CreateJobRemoveXEventFiles
if('2__AllDatabaseObjects' -in $Steps2Execute) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating All Objects in [$DbaDatabase] database.."
    Install-DbaMaintenanceSolution -SqlInstance $SqlInstance -Database $DbaDatabase -Verbose -EnableException
}


# 19__CreateJobRunWhoIsActive
if('2__AllDatabaseObjects' -in $Steps2Execute) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Creating All Objects in [$DbaDatabase] database.."
    Install-DbaMaintenanceSolution -SqlInstance $SqlInstance -Database $DbaDatabase -Verbose -EnableException
}


# 20__WhoIsActivePartition
$stepName = '9__WhoIsActivePartition'
if($stepName -in $Steps2Execute) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "*****Working on step '$stepName'.."
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$WhoIsActivePartitionFilePath = '$WhoIsActivePartitionFilePath'"
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Alter dbo.WhoIsActive to partitioned table.."
    Invoke-DbaQuery -SqlInstance $SqlInstance -Database $DbaDatabase -File $WhoIsActivePartitionFilePath -EnableException
}
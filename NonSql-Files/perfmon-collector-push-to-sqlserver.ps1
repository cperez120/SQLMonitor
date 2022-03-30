[CmdletBinding()]
Param (
    # Set SQL Server where data should be saved
    [Parameter(Mandatory=$false)]
    $SqlInstance = 'localhost',

    [Parameter(Mandatory=$false)]
    $Database = 'DBA',

    [Parameter(Mandatory=$false)]
    $TablePerfmonFiles = '[dbo].[perfmon_files]',

    [Parameter(Mandatory=$false)]
    $TablePerfmonCounters = '[dbo].[performance_counters]',

    [Parameter(Mandatory=$false)]
    $CollectorSetName = 'DBA',

    [Parameter(Mandatory=$false)]
    $ErrorActionPreference = 'Stop',

    [Parameter(Mandatory=$false)]
    [Bool]$CleanupFiles = $true
)

# Fetch Collector details
$startTime = Get-Date
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Fetch details of [$collectorSetName] data collector.."
$pfCollector = Get-DbaPfDataCollector -CollectorSet $collectorSetName
$pfCollectorSet = Get-DbaPfDataCollectorSet -CollectorSet $collectorSetName
$computerName = $pfCollector.ComputerName
$lastFile = $pfCollector.LatestOutputLocation
$pfCollectorFolder = Split-Path $lastFile -Parent
$lastImportedFile = $null

# Get latest imported file
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Fetch details of last imported file from [$SqlInstance].[$Database].$TablePerfmonFiles.."
$lastImportedFile = Invoke-DbaQuery -SqlInstance $SqlInstance -Database $Database -Query "select top 1 file_name from $TablePerfmonFiles where server_name = '$($env:COMPUTERNAME)' order by file_name desc" | Select-Object -ExpandProperty file_name;

# Stop collector set
if($pfCollectorSet.State -eq 'Running') {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Stop data collector.."
    $pfCollectorSet | Stop-DbaPfDataCollectorSet | Out-Null
}

# Note existing files
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Scan existing perfmon files generated.."
$pfCollectorFiles = @()
$pfCollectorFiles += Get-ChildItem $pfCollectorFolder -Recurse -File -Name *.blg | Where-Object {[String]::IsNullOrEmpty($lastImportedFile) -or ($_ -gt $lastImportedFile)} | Sort-Object

# Start collector set
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Start data collector.."
Start-DbaPfDataCollectorSet -CollectorSet $collectorSetName | Out-Null

foreach($file in $pfCollectorFiles)
{
    #Import-Counter -Path "$pfCollectorFolder\21L-LTPABL-1187_DBA_20220325_134853_001.blg" -ListSet * | ogv
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Processing file '$file', and import data into [$SqlInstance].[$Database].$TablePerfmonCounters.."
    try
    {
        Import-Counter -Path "$pfCollectorFolder\$file" -EA silentlycontinue | Select-Object -ExpandProperty CounterSamples | 
                Select-Object @{l='collection_time_utc';e={($_.TimeStamp).ToUniversalTime()}}, @{l='computer_name';e={$computerName}}, @{l='path';e={$_.Path}}, `
                              @{l='object';e={$path = $_.Path; $splitPath = $path.Split('\\')|Where-Object{-not [String]::IsNullOrEmpty($_)}; $object = $splitPath[1]; $object.replace("($($_.InstanceName))",'') }}, `
                              @{l='counter';e={$path = $_.Path; $splitPath = $path.Split('\\')|Where-Object{-not [String]::IsNullOrEmpty($_)}; $splitPath[2] }}, `
                              @{l='value';e={$_.CookedValue}}, @{l='instance';e={$_.InstanceName}} |
                Write-DbaDbTableData -SqlInstance $SqlInstance -Database $Database -Table $TablePerfmonCounters -EnableException
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "File import complete.."

    
        # If blg file is read successfully, then add file entry into database
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Make entry of file in [$SqlInstance].[$Database].[dbo].[perfmon_files].."
        $sqlInsertFile = @"
        insert dbo.perfmon_files (server_name, file_name, file_path)
        select @server_name, @file_name, @file_path;
"@
        Invoke-DbaQuery -SqlInstance $SqlInstance -Database $Database -Query $sqlInsertFile -SqlParameter @{server_name = $env:COMPUTERNAME; file_name = $file; file_path = "$pfCollectorFolder\$file"}
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Entry made.."

        if($CleanupFiles) {
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Remove file.."
            Remove-Item "$pfCollectorFolder\$file"
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "File removed.."
        }
    }
    catch {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Remove file as its generating error.."
        Remove-Item "$pfCollectorFolder\$file"
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "File removed.."
    }
}
"`n`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'END:', "All files processed.."


[CmdletBinding()]
Param (
    # Set SQL Server where data should be saved
    [Parameter(Mandatory=$false)]
    $SqlInstance = 'localhost',

    [Parameter(Mandatory=$false)]
    $Database = 'DBA',

    [Parameter(Mandatory=$false)]
    $HostName = $env:COMPUTERNAME,

    [Parameter(Mandatory=$false)]
    $TablePerfmonFiles = '[dbo].[perfmon_files]',

    [Parameter(Mandatory=$false)]
    $TablePerfmonCounters = '[dbo].[performance_counters]',

    [Parameter(Mandatory=$false)]
    $CollectorSetName = 'DBA',

    [Parameter(Mandatory=$false)]
    $ErrorActionPreference = 'Stop',

    [Parameter(Mandatory=$false)]
    [Bool]$CleanupFiles = $true,

    [Parameter(Mandatory=$false)]
    [int]$FileCleanupThresholdHours = 48
)

$startTime = Get-Date
Import-Module dbatools;
$ErrorActionPreference = 'Stop'


# Fetch Collector details
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Fetch details of [$collectorSetName] data collector.."

$dataCollectorSet = New-Object -COM Pla.DataCollectorSet;
$dataCollectorSet.Query($CollectorSetName,$HostName);

<#
$dataCollectorSet | gm
$dataCollectorSet.LatestOutputLocation
$dataCollectorSet.DataCollectors | gm
$dataCollectorSet.DataCollectors[0].LatestOutputLocation
$dataCollectorSet.Status
$dataCollectorSet.start($true)
$dataCollectorSet.Stop($true)
#>

#$pfCollector = Get-DbaPfDataCollector -ComputerName $HostName -CollectorSet $collectorSetName
#$pfCollectorSet = Get-DbaPfDataCollectorSet -ComputerName $HostName -CollectorSet $collectorSetName
#$computerName = $pfCollector.ComputerName
$computerName = $dataCollectorSet.Server
#$lastFile = $pfCollector.LatestOutputLocation
$lastFile = $dataCollectorSet.DataCollectors[0].LatestOutputLocation
if([String]::IsNullOrEmpty($lastFile)) {
    $pfCollectorFolder = "$PSScriptRoot\Perfmon-Files"
}
else {
    $pfCollectorFolder = Split-Path $lastFile -Parent
}
$lastImportedFile = $null

# Get latest imported file
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Fetch details of last imported file from [$SqlInstance].[$Database].$TablePerfmonFiles.."
$lastImportedFile = Invoke-DbaQuery -SqlInstance $SqlInstance -Database $Database -Query "select top 1 file_name from $TablePerfmonFiles where host_name = '$computerName' and file_name like '$computerName%' order by file_name desc" | Select-Object -ExpandProperty file_name;
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$lastImportedFile => '$lastImportedFile'."

# Stop collector set
#if($pfCollectorSet.State -eq 'Running') {
if($dataCollectorSet.Status -eq 1) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Stop data collector.."
    #$pfCollectorSet | Stop-DbaPfDataCollectorSet | Out-Null
    $dataCollectorSet.Stop($true) | Out-Null
}

# Note existing files
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Scan existing perfmon files generated.."
$perfmonFilesFound = @()
$pfCollectorFiles = @()
$perfmonFilesDirectory = $("\\$computerName\"+$pfCollectorFolder.Replace(':','$'))
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "`$perfmonFilesDirectory => '$perfmonFilesDirectory'."
$perfmonFilesFound += Get-ChildItem $perfmonFilesDirectory -Recurse -File -Name *.blg
$pfCollectorFiles += $perfmonFilesFound | Where-Object {[String]::IsNullOrEmpty($lastImportedFile) -or ($_ -gt $lastImportedFile)} | Sort-Object
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "$($perfmonFilesFound.Count) files found. $($pfCollectorFiles.Count) qualify for import into tables."

# Start collector set
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Start data collector.."
#Start-DbaPfDataCollectorSet -ComputerName $computerName -CollectorSet $collectorSetName | Out-Null
$dataCollectorSet.start($true)

foreach($file in $pfCollectorFiles)
{
    Write-Debug "Inside each file loop"
    #Import-Counter -Path "$pfCollectorFolder\21L-LTPABL-1187_DBA_20220325_134853_001.blg" -ListSet * | ogv
    "`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Processing file '$file', and import data into [$SqlInstance].[$Database].$TablePerfmonCounters.."
    try
    {
        #Import-Counter -Path "$pfCollectorFolder\$file" -EA silentlycontinue | Select-Object -ExpandProperty CounterSamples | 
        Import-Counter -Path "$("\\$computerName\"+$pfCollectorFolder.Replace(':','$'))\$file" -EA silentlycontinue | Select-Object -ExpandProperty CounterSamples | 
                Select-Object @{l='collection_time_utc';e={($_.TimeStamp).ToUniversalTime()}}, @{l='host_name';e={$computerName}}, @{l='path';e={$_.Path}}, `
                              @{l='object';e={
                                    $path = $_.Path; 
                                    $pathWithoutComputerName = ($path -replace "$computerName","").TrimStart('\\');
                                    if( (-not [String]::IsNullOrEmpty($_.InstanceName)) -and $_.InstanceName.Contains('\') ) {
                                        $splitPath = $pathWithoutComputerName.Replace($_.InstanceName,'').Split('()\') | Where-Object {-not [String]::IsNullOrEmpty($_)}
                                    } else {
                                        if([String]::IsNullOrEmpty($_.InstanceName)) {
                                            $splitPath = $pathWithoutComputerName.Split('\') | Where-Object{-not [String]::IsNullOrEmpty($_)}
                                        }
                                        else {
                                            $splitPath = $pathWithoutComputerName.Replace($_.InstanceName,'').Split('()\') | Where-Object{-not [String]::IsNullOrEmpty($_)}
                                        }
                                    };
                                    $splitPath[0]
                               }}, `
                              @{l='counter';e={
                                    $path = $_.Path; 
                                    $pathWithoutComputerName = ($path -replace "$computerName","").TrimStart('\\');
                                    if( (-not [String]::IsNullOrEmpty($_.InstanceName)) -and $_.InstanceName.Contains('\') ) {
                                        $splitPath = $pathWithoutComputerName.Replace($_.InstanceName,'').Split('()\') | Where-Object {-not [String]::IsNullOrEmpty($_)}
                                    } else {
                                        if([String]::IsNullOrEmpty($_.InstanceName)) {
                                            $splitPath = $pathWithoutComputerName.Split('\') | Where-Object{-not [String]::IsNullOrEmpty($_)}
                                        }
                                        else {
                                            $pathWithoutInstance = $pathWithoutComputerName.Replace($_.InstanceName,'')
                                            $splitPath = $($pathWithoutInstance -split '()\', 0, "simplematch") | Where-Object{-not [String]::IsNullOrEmpty($_)}
                                        }
                                    };
                                    $splitPath[1]
                               }}, `
                              @{l='value';e={$_.CookedValue}}, @{l='instance';e={$_.InstanceName}} |
                Write-DbaDbTableData -SqlInstance $SqlInstance -Database $Database -Table $TablePerfmonCounters -EnableException
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "File import complete.."

    
        # If blg file is read successfully, then add file entry into database
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Make entry of file in [$SqlInstance].[$Database].$TablePerfmonFiles.."
        $sqlInsertFile = @"
        insert $TablePerfmonFiles (host_name, file_name, file_path)
        select @host_name, @file_name, @file_path;
"@
        Invoke-DbaQuery -SqlInstance $SqlInstance -Database $Database -Query $sqlInsertFile -SqlParameter @{host_name = $computerName; file_name = $file; file_path = "$pfCollectorFolder\$file"} -EnableException
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Entry made.."

        if($CleanupFiles) {
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Remove file.."
            #Remove-Item "$pfCollectorFolder\$file"
            Remove-Item "$("\\$computerName\"+$pfCollectorFolder.Replace(':','$'))\$file"
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "File removed.."
        }
    }
    catch {
        $errMessage = $_;
        $errMessage.Exception | Select * | fl

        # Handle error "No valid counter paths were found in the files" which happens when OS is restarted, and file becomes invalid
        if($errMessage.Exception.Message -like '*No valid counter paths were found in the files*')
        {
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Got error '$($errMessage.Exception.Message)' while reading '$file'."

            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Trying to skip the file.." 
            $sqlInsertFile = @"
            insert $TablePerfmonFiles (host_name, file_name, file_path)
            select @host_name, @file_name, @file_path;
"@
            Invoke-DbaQuery -SqlInstance $SqlInstance -Database $Database -Query $sqlInsertFile -SqlParameter @{host_name = $computerName; file_name = $file; file_path = "$pfCollectorFolder\$file"} -EnableException
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Skip Entry made into [$SqlInstance].[$Database].$TablePerfmonFiles.."

            # Try to remove file for which we got error
            try {
                "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Remove file as its generating error.."
                Remove-Item "$("\\$computerName\"+$pfCollectorFolder.Replace(':','$'))\$file"
                "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "File removed.."
            }
            catch {
                "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'ERROR:', "Failed to remove file due to error '$($_.Exception.Message)'.."
            }
        }
    }
}

# Remove older files
if($CleanupFiles) {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Search files older than $FileCleanupThresholdHours hours.."
    $oldFilesForCleanup = @()
    $oldFilesForCleanup += Get-ChildItem $perfmonFilesDirectory -Recurse -File -Name *.blg | Where-Object {$_.LastWriteTimeUtc -lt (Get-Date).AddHours(-$FileCleanupThresholdHours)}

    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "$($oldFilesForCleanup.Count) files detected older than $FileCleanupThresholdHours hours."
    if($oldFilesForCleanup.Count -gt 0) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Remove above detected old files.."
        $oldFilesForCleanup | Remove-Item -ErrorAction Ignore | Out-Null
    }    
}

"`n`n$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'END:', "All files processed.."
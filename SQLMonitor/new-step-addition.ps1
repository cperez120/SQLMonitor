[CmdletBinding()]
Param (
    [Parameter(Mandatory=$false)]
    [String]$NewStepName = "11__RemoveJob_CheckInstanceAvailability",
    
    [Parameter(Mandatory=$false)]
    [String[]]$AllSteps = @( "1__RemoveJob_CollectDiskSpace", "2__RemoveJob_CollectOSProcesses", "3__RemoveJob_CollectPerfmonData",
                "4__RemoveJob_CollectWaitStats", "5__RemoveJob_CollectXEvents", "6__RemoveJob_PartitionsMaintenance",
                "7__RemoveJob_PurgeTables", "8__RemoveJob_RemoveXEventFiles", "9__RemoveJob_RunWhoIsActive",
                "10__RemoveJob_UpdateSqlServerVersions", "11__DropProc_UspExtendedResults", "12__DropProc_UspCollectWaitStats",
                "13__DropProc_UspRunWhoIsActive", "14__DropProc_UspCollectXEventsResourceConsumption", "15__DropProc_UspPartitionMaintenance",
                "16__DropProc_UspPurgeTables", "17__DropProc_SpWhatIsRunning", "18__DropView_VwPerformanceCounters",
                "19__DropView_VwOsTaskList", "20__DropView_VwWaitStatsDeltas", "21__DropXEvent_ResourceConsumption",
                "22__DropLinkedServer", "23__DropLogin_Grafana", "24__DropTable_ResourceConsumption",
                "25__DropTable_ResourceConsumptionProcessedXELFiles", "26__DropTable_WhoIsActive_Staging", "27__DropTable_WhoIsActive",
                "28__DropTable_PerformanceCounters", "29__DropTable_PurgeTable", "30__DropTable_PerfmonFiles",
                "31__DropTable_InstanceHosts", "32__DropTable_OsTaskList", "33__DropTable_BlitzWho",
                "34__DropTable_BlitzCache", "35__DropTable_ConnectionHistory", "36__DropTable_BlitzFirst",
                "37__DropTable_BlitzFirstFileStats", "38__DropTable_InstanceDetails", "39__DropTable_DiskSpace",
                "40__DropTable_BlitzFirstPerfmonStats", "41__DropTable_BlitzFirstWaitStats", "42__DropTable_BlitzFirstWaitStatsCategories",
                "43__DropTable_WaitStats", "44__RemovePerfmonFilesFromDisk", "45__RemoveXEventFilesFromDisk",
                "46__DropProxy", "47__DropCredential"
                ),

    [Parameter(Mandatory=$false)]
    [Bool]$PrintUserFriendlyFormat = $true,

    [Parameter(Mandatory=$false)]
    [String]$ScriptFile = 'F:\GitHub\SQLMonitor\SQLMonitor\Remove-SQLMonitor.ps1'
                          #'F:\GitHub\SQLMonitor\SQLMonitor\Install-SQLMonitor.ps1'
)

cls

# Placeholders
$newSteps = @()

# Calculations
[int]$newStepNo = $NewStepName -replace "__\w+", ''
$preStep = $newStepNo-2;
$postStep = $newStepNo-1;
$lastStep = $AllSteps.Count-1;

#"Pre-Steps" | Write-Host -ForegroundColor Green
$preNewSteps = @()
$preNewSteps += $AllSteps[0..$preStep]

#"`nAdd step '$NewStepName' here`n" | Write-Host -ForegroundColor Cyan

#"Post-Steps" | Write-Host -ForegroundColor Green
$postNewSteps = @()
$postNewSteps += $AllSteps[$postStep..$lastStep] | ForEach-Object {[int]$stepNo = $_ -replace "__\w+", ''; $_.Replace("$stepNo", "$($stepNo+1)")}

$newSteps = $preNewSteps + @($NewStepName) + $postNewSteps

"All New Steps => `n`n " | Write-Host -ForegroundColor Green
if($PrintUserFriendlyFormat) {
    foreach($num in $(0..$([Math]::Floor($newSteps.Count/3)))) {
        $numStart = ($num*3)
        $numEnd = ($num*3)+2
        #"`$num = $num, `$numStart = $numStart, `$numEnd = $numEnd"        
        
        "                " + $(($newSteps[$numStart..$numEnd] | ForEach-Object {'"'+$_+'"'}) -join ', ') + $(if($num -ne $([Math]::Floor($newSteps.Count/3))){","})
        
    }
}
else {
    $newSteps
}

if([String]::IsNullOrEmpty($ScriptFile)) {
    "`n`nNo file provided to replace the content."
} else {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Read file content.."
    $fileContent = [System.IO.File]::ReadAllText($ScriptFile)
    foreach($index in $($postStep..$($AllSteps.Count-1))) {
        #"Replace '$($AllSteps[$index])' with '$($newSteps[$index])'"
        $fileContent = $fileContent.Replace($AllSteps[$index],$newSteps[$index+1]);
    }
    $newScriptFile = $ScriptFile.Replace('.ps1',' __bak.ps1')
    $fileContent | Out-File -FilePath $newScriptFile
    notepad $newScriptFile
    "Updated data saved into file '$newScriptFile'." | Write-Host -ForegroundColor Green
    "Opening saved file '$newScriptFile'." | Write-Host -ForegroundColor Green
}






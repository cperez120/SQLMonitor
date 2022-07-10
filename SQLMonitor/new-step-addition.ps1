[CmdletBinding()]
Param (
    [Parameter(Mandatory=$false)]
    [String]$NewStepName = "15__DropProc_UspPartitionMaintenance",
    
    [Parameter(Mandatory=$false)]
    [String[]]$AllSteps = @(  "1__RemoveJob_CollectDiskSpace", "2__RemoveJob_CollectOSProcesses", "3__RemoveJob_CollectPerfmonData",
                "4__RemoveJob_CollectWaitStats", "5__RemoveJob_CollectXEvents", "6__RemoveJob_PartitionsMaintenance",
                "7__RemoveJob_PurgeTables", "8__RemoveJob_RemoveXEventFiles", "9__RemoveJob_RunWhoIsActive",
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






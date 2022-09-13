[CmdletBinding()]
Param (
    [Parameter(Mandatory=$false)]
    [ValidateSet("AddStep", "RemoveStep")]
    [String]$Action = "AddStep",

    [Parameter(Mandatory=$false)]
    [String]$StepName = "5__SomeNewStepName",
    
    [Parameter(Mandatory=$false)]
    [String[]]$AllSteps = @( "1__RemoveJob_CollectDiskSpace", "2__RemoveJob_CollectOSProcesses", "3__RemoveJob_CollectPerfmonData",
                "4__RemoveJob_CollectWaitStats", "5__RemoveJob_CollectXEvents", "6__RemoveJob_PartitionsMaintenance",
                "7__RemoveJob_PurgeTables", "8__RemoveJob_RemoveXEventFiles", "9__RemoveJob_RunWhoIsActive",
                "10__RemoveJob_UpdateSqlServerVersions", "11__RemoveJob_CheckInstanceAvailability", "12__DropProc_UspExtendedResults",
                "13__DropProc_UspCollectWaitStats", "14__DropProc_UspRunWhoIsActive", "15__DropProc_UspCollectXEventsResourceConsumption",
                "16__DropProc_UspPartitionMaintenance", "17__DropProc_UspPurgeTables", "18__DropProc_SpWhatIsRunning",
                "19__DropView_VwPerformanceCounters", "20__DropView_VwOsTaskList", "21__DropView_VwWaitStatsDeltas",
                "22__DropXEvent_ResourceConsumption", "23__DropLinkedServer", "24__DropLogin_Grafana",
                "25__DropTable_ResourceConsumption", "26__DropTable_ResourceConsumptionProcessedXELFiles", "27__DropTable_WhoIsActive_Staging",
                "28__DropTable_WhoIsActive", "29__DropTable_PerformanceCounters", "30__DropTable_PurgeTable",
                "31__DropTable_PerfmonFiles", "32__DropTable_InstanceDetails", "33__DropTable_InstanceHosts",
                "34__DropTable_OsTaskList", "35__DropTable_BlitzWho", "36__DropTable_BlitzCache",
                "37__DropTable_ConnectionHistory", "38__DropTable_BlitzFirst", "39__DropTable_BlitzFirstFileStats",
                "40__DropTable_DiskSpace", "41__DropTable_BlitzFirstPerfmonStats", "42__DropTable_BlitzFirstWaitStats",
                "43__DropTable_BlitzFirstWaitStatsCategories", "44__DropTable_WaitStats", "45__RemovePerfmonFilesFromDisk",
                "46__RemoveXEventFilesFromDisk", "47__DropProxy", "48__DropCredential", "49__RemoveInstanceFromInventory"
                ),

    [Parameter(Mandatory=$false)]
    [Bool]$PrintUserFriendlyFormat = $true,

    [Parameter(Mandatory=$false)]
    [String]$ScriptFile = 'F:\GitHub\SQLMonitor\SQLMonitor\Remove-SQLMonitor.ps1'
                          #'F:\GitHub\SQLMonitor\SQLMonitor\Install-SQLMonitor.ps1'
)

cls

# Placeholders
$finalSteps = @()

# Calculations
[int]$paramStepNo = $StepName -replace "__\w+", ''
$preStep = $paramStepNo-2;
if($Action -eq "AddStep") { # Add New Step
    $postStep = $paramStepNo-1;
    $lastStep = $AllSteps.Count-1;
}
else { # Remove Existing Step
    $postStep = $paramStepNo;
    $lastStep = $AllSteps.Count-1;
}

#"Pre-Steps" | Write-Host -ForegroundColor Green
$preNewSteps = @()
$preNewSteps += $AllSteps[0..$preStep]

#"`nAdd step '$StepName' here`n" | Write-Host -ForegroundColor Cyan

#"Post-Steps" | Write-Host -ForegroundColor Green
$postNewSteps = @()
if($Action -eq "AddStep") { # Add New Step
    $postNewSteps += $AllSteps[$postStep..$lastStep] | 
        ForEach-Object {[int]$stepNo = $_ -replace "__\w+", ''; $_.Replace("$stepNo", "$($stepNo+1)")}
    $finalSteps = $preNewSteps + @($StepName) + $postNewSteps
}
else { # Remove Existing Step
    $postNewSteps += $AllSteps[$postStep..$lastStep] | 
        ForEach-Object {[int]$stepNo = $_ -replace "__\w+", ''; $_.Replace("$stepNo", "$($stepNo-1)")}
    $finalSteps = $preNewSteps + $postNewSteps
}



"All New Steps => `n`n " | Write-Host -ForegroundColor Green
if($PrintUserFriendlyFormat) {
    foreach($num in $(0..$([Math]::Floor($finalSteps.Count/3)))) {
        $numStart = ($num*3)
        $numEnd = ($num*3)+2
        #"`$num = $num, `$numStart = $numStart, `$numEnd = $numEnd"        
        
        "                " + $(($finalSteps[$numStart..$numEnd] | ForEach-Object {'"'+$_+'"'}) -join ', ') + $(if($num -ne $([Math]::Floor($finalSteps.Count/3))){","})
        
    }
}
else {
    $finalSteps
}

if([String]::IsNullOrEmpty($ScriptFile)) {
    "`n`nNo file provided to replace the content."
} else {
    "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Read file content.."
    $fileContent = [System.IO.File]::ReadAllText($ScriptFile)
    foreach($index in $($postStep..$($AllSteps.Count-1))) 
    {
        if($Action -eq "AddStep") { # Add New Step
            $fileContent = $fileContent.Replace($AllSteps[$index],$finalSteps[$index+1]);
        }
        else { # Remove Existing Step
            $fileContent = $fileContent.Replace($AllSteps[$index],$finalSteps[$index-1]);
        }
    }
    $newScriptFile = $ScriptFile.Replace('.ps1',' __bak.ps1')
    $fileContent | Out-File -FilePath $newScriptFile
    notepad $newScriptFile
    "Updated data saved into file '$newScriptFile'." | Write-Host -ForegroundColor Green
    "Opening saved file '$newScriptFile'." | Write-Host -ForegroundColor Green
}


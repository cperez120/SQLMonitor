[CmdletBinding()]
Param (
    [Parameter(Mandatory=$false)]
    [ValidateSet("AddStep", "RemoveStep")]
    [String]$Action = "AddStep",

    [Parameter(Mandatory=$false)]
    [String]$StepName = "24__CreateJobCollectMemoryClerks",
    
    [Parameter(Mandatory=$false)]
    [String[]]$AllSteps = @( "1__sp_WhoIsActive", "2__AllDatabaseObjects", "3__XEventSession",
                "4__FirstResponderKitObjects", "5__DarlingDataObjects", "6__sp_WhatIsRunning",
                "7__usp_GetAllServerInfo", "8__CopyDbaToolsModule2Host", "9__CopyPerfmonFolder2Host",
                "10__SetupPerfmonDataCollector", "11__CreateCredentialProxy", "12__CreateJobCollectDiskSpace",
                "13__CreateJobCollectOSProcesses", "14__CreateJobCollectPerfmonData", "15__CreateJobCollectWaitStats",
                "16__CreateJobCollectXEvents", "17__CreateJobCollectFileIOStats", "18__CreateJobPartitionsMaintenance",
                "19__CreateJobPurgeTables", "20__CreateJobRemoveXEventFiles", "21__CreateJobRunWhoIsActive",
                "22__CreateJobRunBlitzIndex", "23__CreateJobRunBlitzIndexWeekly", "24__CreateJobUpdateSqlServerVersions",
                "25__CreateJobCheckInstanceAvailability", "26__CreateJobGetAllServerInfo", "27__WhoIsActivePartition",
                "28__BlitzIndexPartition", "29__EnablePageCompression", "30__GrafanaLogin",
                "31__LinkedServerOnInventory", "32__LinkedServerForDataDestinationInstance", "33__AlterViewsForDataDestinationInstance"
                ),

    [Parameter(Mandatory=$false)]
    [Bool]$PrintUserFriendlyFormat = $true,

    [Parameter(Mandatory=$false)]
    [String]$ScriptFile = #'F:\GitHub\SQLMonitor\SQLMonitor\Remove-SQLMonitor.ps1'
                          #'F:\GitHub\SQLMonitor\SQLMonitor\Install-SQLMonitor.ps1'
                          'D:\Github\SQLMonitor\SQLMonitor\Install-SQLMonitor.ps1'
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


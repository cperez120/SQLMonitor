[CmdletBinding()]
Param (
    [Parameter(Mandatory=$false)]
    [String]$NewStepName = "13__CreateJobCollectDiskSpace",
    
    [Parameter(Mandatory=$false)]
    [String[]]$AllSteps = @(  "1__sp_WhoIsActive", "2__AllDatabaseObjects", "3__XEventSession",
                "4__FirstResponderKitObjects", "5__DarlingDataObjects", "6__OlaHallengrenSolutionObjects",
                "7__sp_WhatIsRunning", "8__usp_GetAllServerInfo", "9__CopyDbaToolsModule2Host",
                "10__CopyPerfmonFolder2Host", "11__SetupPerfmonDataCollector", "12__CreateCredentialProxy",
                "13__CreateJobCollectOSProcesses", "14__CreateJobCollectPerfmonData", "15__CreateJobCollectWaitStats",
                "16__CreateJobCollectXEvents", "17__CreateJobPartitionsMaintenance", "18__CreateJobPurgeTables",
                "19__CreateJobRemoveXEventFiles", "20__CreateJobRunWhoIsActive", "21__CreateJobUpdateSqlServerVersions",
                "22__WhoIsActivePartition", "23__GrafanaLogin", "24__LinkedServerOnInventory"
                ),

    [Parameter(Mandatory=$false)]
    [Bool]$PrintUserFriendlyFormat = $true,

    [Parameter(Mandatory=$false)]
    [String]$ScriptFile = 'F:\GitHub\SQLMonitor\SQLMonitor\Install-SQLMonitor.ps1'
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






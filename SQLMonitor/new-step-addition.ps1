[CmdletBinding()]
Param (
    [Parameter(Mandatory=$false)]
    [String]$NewStepName = "24__CreateJobGetAllServerInfo",
    
    [Parameter(Mandatory=$false)]
    [String[]]$AllSteps = @( "1__sp_WhoIsActive", "2__AllDatabaseObjects", "3__XEventSession",
                "4__FirstResponderKitObjects", "5__DarlingDataObjects", "6__OlaHallengrenSolutionObjects",
                "7__sp_WhatIsRunning", "8__usp_GetAllServerInfo", "9__CopyDbaToolsModule2Host",
                "10__CopyPerfmonFolder2Host", "11__SetupPerfmonDataCollector", "12__CreateCredentialProxy",
                "13__CreateJobCollectDiskSpace", "14__CreateJobCollectOSProcesses", "15__CreateJobCollectPerfmonData",
                "16__CreateJobCollectWaitStats", "17__CreateJobCollectXEvents", "18__CreateJobPartitionsMaintenance",
                "19__CreateJobPurgeTables", "20__CreateJobRemoveXEventFiles", "21__CreateJobRunWhoIsActive",
                "22__CreateJobUpdateSqlServerVersions", "23__CreateJobCheckInstanceAvailability", "24__WhoIsActivePartition",
                "25__GrafanaLogin", "26__LinkedServerOnInventory", "27__LinkedServerForDataDestinationInstance",
                "28__AlterViewsForDataDestinationInstance"
                ),

    [Parameter(Mandatory=$false)]
    [Bool]$PrintUserFriendlyFormat = $true,

    [Parameter(Mandatory=$false)]
    [String]$ScriptFile = #'F:\GitHub\SQLMonitor\SQLMonitor\Remove-SQLMonitor.ps1'
                          'F:\GitHub\SQLMonitor\SQLMonitor\Install-SQLMonitor.ps1'
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






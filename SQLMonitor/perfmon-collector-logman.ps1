[CmdletBinding()]
Param (
    [Parameter(Mandatory=$false)]
    $TemplatePath = “C:\SQLMonitor\DBA_PerfMon_All_Counters_Template.xml”,
    [Parameter(Mandatory=$false)]
    $CollectorSetName = "DBA",
    [Parameter(Mandatory=$false)]
    [bool]$WhatIf = $false
)


# Find Perfmon data collection logs folder path
$collector_root_directory = Split-Path $TemplatePath -Parent
$log_file_path = "$collector_root_directory\Perfmon-Files\$CollectorSetName"
$file_rotation_time = '00:05:00'
$sample_interval = '00:00:30'

# Get named instances installed on box
"Finding sql instances on host.." | Write-Host -ForegroundColor Cyan
$sqlInstances = @()
$sqlInstances +=  (Get-Service *sql* | ? {$_.Name -ne 'MSSQLSERVER' -and $_.DisplayName -match '^SQL Server \(.+\)$'} | Select-Object -ExpandProperty Name)

# Add counters for named instances
if($sqlInstances.Count -gt 0)
{
    "Add counters for named instances ($($sqlInstances -join ',')).." | Write-Host -ForegroundColor Cyan
    # https://stackoverflow.com/questions/16428559/powershell-script-to-update-xml-file-content

    # read template data into xml object
    [xml]$xmlDoc = (Get-Content $TemplatePath)

    # segregate sql & os counters
    $sqlCounters = @()
    $osCounters = @()
    foreach($cntr in $xmlDoc.DataCollectorSet.PerformanceCounterDataCollector.Counter) {
        if($cntr -match '^\\SQLServer:.*') {
            $sqlCounters += $cntr
        }
        else {
            $osCounters += $cntr
        }
    }

    <#
    # remove existing sql counters
    $matchingNodes = $xmlDoc.SelectNodes("//Counter")
    foreach($node in $matchingNodes){
        if($node."#text" -match '^\\SQLServer:.*') {
            $xmlDoc.DataCollectorSet.PerformanceCounterDataCollector.RemoveChild($node)
        }
    }
    #>

    # Loop through each named instance
    foreach($sqlInst in $sqlInstances) {
        # Loop through each sql counter
        foreach($cntr in $sqlCounters) {
            $counterElement = $xmlDoc.CreateElement("Counter")
            $counterElement.InnerText = $cntr.Replace('\SQLServer:',('\'+$sqlInst+':'))
            $xmlDoc.DataCollectorSet.PerformanceCounterDataCollector.AppendChild($counterElement) | Out-Null
        }
    }

    #save the changes
    $tempFile = $collector_root_directory+"\$(Get-Random).xml"
    "Creating new temporary template file '$tempFile'.." | Write-Host -ForegroundColor Cyan
    $xmlDoc.Save($tempFile)

    $TemplatePath = $tempFile
}

# Create data collector from template, update sample & rotation time, and start collector
if(-not $WhatIf) {
    "Creating Collector Set [$CollectorSetName] from template [$TemplatePath].." | Write-Host -ForegroundColor Cyan
    logman import -name “$CollectorSetName” -xml “$TemplatePath”
    "Updating Collector Set [$CollectorSetName] with sample interval, rotation time, and output file path.." | Write-Host -ForegroundColor Cyan
    logman update -name “$CollectorSetName” -f bin -cnf "$file_rotation_time" -o "$log_file_path" -si "$sample_interval"
    "Starting Collector Set [$CollectorSetName].." | Write-Host -ForegroundColor Cyan
    logman start -name “$CollectorSetName”
}

if([System.IO.File]::Exists($tempFile)) {
    "Removing temporary template file [$tempFile].." | Write-Host -ForegroundColor Cyan
    Remove-Item -Path $tempFile -WhatIf:$WhatIf
}
<#
logman stop -name “$CollectorSetName”
logman delete -name “$CollectorSetName”

Get-Counter -ListSet * | Select-Object -ExpandProperty Counter | ogv
#>


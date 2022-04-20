cls

# Copy paste the template file on folder that would contain Perfmon data collection logs
    # Point the template path
$data_collector_template_path = “Y:\Perfmon\DBA_PerfMon_All_Counters_Template.xml”;
$data_collector_set_name = 'DBA';
[bool]$WhatIf = $false

# Find Perfmon data collection logs folder path
$collector_root_directory = Split-Path $data_collector_template_path -Parent
$log_file_path = "$collector_root_directory\$data_collector_set_name"
$file_rotation_time = '00:30:00'
$sample_interval = '00:00:10'

# Get named instances installed on box
$sqlInstances = @()
$sqlInstances +=  (Get-Service *sql* | ? {$_.Name -ne 'MSSQLSERVER' -and $_.DisplayName -match '^SQL Server \(.+\)$'} | Select-Object -ExpandProperty Name)

# Add counters for named instances
if($sqlInstances.Count -gt 0)
{
    # https://stackoverflow.com/questions/16428559/powershell-script-to-update-xml-file-content

    # read template data into xml object
    [xml]$xmlDoc = (Get-Content $data_collector_template_path)

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
    $xmlDoc.Save($tempFile)

    $data_collector_template_path = $tempFile
}

# Create data collector from template, update sample & rotation time, and start collector
if(-not $WhatIf) {
    logman import -name “$data_collector_set_name” -xml “$data_collector_template_path”
    logman update -name “$data_collector_set_name” -f bin -cnf "$file_rotation_time" -o "$log_file_path" -si "$sample_interval"
    logman start -name “$data_collector_set_name”
}
else {
    "Perfmon template '$data_collector_template_path' created for execution." | Write-Host -ForegroundColor Yellow
}

Remove-Item -Path $tempFile -WhatIf:$WhatIf
<#
logman stop -name “$data_collector_set_name”
logman delete -name “$data_collector_set_name”

Get-Counter -ListSet * | Select-Object -ExpandProperty Counter | ogv
#>


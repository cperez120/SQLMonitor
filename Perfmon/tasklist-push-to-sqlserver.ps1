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
    $TableName = '[dbo].[os_task_list]'
)

Import-Module dbatools;
$timeUTC = (Get-Date).ToUniversalTime()

"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Get running processes on OS, and export them to SqlServer [$SqlInstance].[$Database].$TableName.."
$taskList = @()
if($env:COMPUTERNAME -eq $HostName) {
    $taskList += TASKLIST /v /fo csv | ConvertFrom-Csv
}
else {
    $taskList += TASKLIST /s $HostName /v /fo csv | ConvertFrom-Csv
} 

$taskList | Select @{l='collection_time_utc';e={$timeUTC}}, @{l='host_name';e={$HostName}}, @{l='task_name';e={$_.'Image Name'}}, @{l='pid';e={$_.PID}}, `
                @{l='session_name';e={$_.'Session Name'}}, @{l='memory_kb';e={$mem = $_.'Mem Usage'; [bigint]($mem.Replace(',', '') -replace ' K','')}}, `
                @{l='status';e={$status = $_.'Status'; if($status -eq 'Unknown'){$null}else{$_.'Status'}}}, `
                @{l='user_name';e={$_.'User Name'}}, @{l='cpu_time';e={$_.'CPU Time'}}, `
                @{l='cpu_time_seconds';e={$cpu_time_parts = $($_.'CPU Time') -split ':'; (New-TimeSpan -Hours $cpu_time_parts[0] -Minutes $cpu_time_parts[1] -Seconds $cpu_time_parts[2]).TotalSeconds}}, `
                @{l='window_title';e={$title = $_.'Window Title'; if($title -eq 'N/A'){$null}else{$title}}} | #ogv
        Write-DbaDbTableData -SqlInstance $SqlInstance -Database $Database -Table $TableName -EnableException -AutoCreateTable
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Export completed."


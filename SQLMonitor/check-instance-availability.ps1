[CmdletBinding()]
Param (
    # Set SQL Server where data should be saved
    [Parameter(Mandatory=$false)]
    $InventoryServer = 'localhost',

    [Parameter(Mandatory=$false)]
    $InventoryDatabase = 'DBA',

    [Parameter(Mandatory=$false)]
    $Threads = 4
)

Import-Module dbatools
Import-Module PoshRSJob -WarningAction Continue;

$ErrorActionPreference = 'Stop'
$currentTime = Get-Date

"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Get all SQLInstances in SQLMonitor server [$InventoryServer].[dbo].[instance_details].."
$sqlSupportedInstances = "select distinct [sql_instance], [database] from dbo.instance_details" 
$supportedInstances = @()
$supportedInstances += Invoke-DbaQuery -SqlInstance $InventoryServer -Database $InventoryDatabase -Query $sqlSupportedInstances -EnableException

"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Below SQLInstances found in dbo.instance_details-"
"`n($(($supportedInstances.sql_instance|%{"'$_'"}) -join ','))`n"

# Create Grafana Credential
$username = "grafana"
$password = ConvertTo-SecureString "grafana" -AsPlainText -Force
$sqlCredential = New-Object System.Management.Automation.PSCredential -ArgumentList ($username, $password)

# Loop through each SQLInstance
$blockGetServerHealth = {
    $sqlInstanceDetails = $_;
    $sqlInstance = $sqlInstanceDetails.sql_instance
    $dbaDatabase = $sqlInstanceDetails.database
    #"`$sqlInstance => $sqlInstance"

    Import-Module dbatools
    Invoke-DbaQuery -SqlInstance $SqlInstance -Database $database -Query "select [sql_instance] = '$sqlInstance', [database] = db_name();" -SqlCredential $Using:sqlCredential -EnableException;
}

"{0} {1,-10} {2}" -f "($((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')))","(INFO)","Start RSJobs with $Threads threads.." | Write-Output
$jobs = @()
$jobs += $supportedInstances | Start-RSJob -Name {"$($_.sql_instance)"} -ScriptBlock $blockGetServerHealth -Throttle $Threads
"{0} {1,-10} {2}" -f "($((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')))","(INFO)","Waiting for RSJobs to complete.." | Write-Verbose
$jobs | Wait-RSJob -ShowProgress -Timeout 1200 -Verbose:$false | Out-Null

Write-Debug "Inside check-server-availability"

$jobs_timedout = @()
$jobs_timedout += $jobs | Where-Object {$_.State -in ('NotStarted','Running','Stopping')}
$jobs_success = @()
$jobs_success += $jobs | Where-Object {$_.State -eq 'Completed' -and $_.HasErrors -eq $false}
$jobs_fail = @()
$jobs_fail += $jobs | Where-Object {$_.HasErrors -or $_.State -in @('Disconnected')}

$jobsResult = @()
$jobsResult += $jobs_success | Receive-RSJob -Verbose:$false
    
if($jobs_success.Count -gt 0) {
    "{0} {1,-10} {2}" -f "($((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')))","(INFO)","Below jobs finished without error.." | Write-Output
    $jobs_success | Select-Object Name, State, HasErrors | Format-Table -AutoSize | Out-String | Write-Output
}

if($jobs_timedout.Count -gt 0)
{
    "{0} {1,-10} {2}" -f "($((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')))","(ERROR)","Some jobs timed out. Could not completed in 20 minutes." | Write-Output
    $jobs_timedout | Format-Table -AutoSize | Out-String | Write-Output
    "{0} {1,-10} {2}" -f "($((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')))","(INFO)","Stop timedout jobs.." | Write-Output
    $jobs_timedout | Stop-RSJob
}

if($jobs_fail.Count -gt 0)
{
    "{0} {1,-10} {2}" -f "($((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')))","(ERROR)","Some jobs failed." | Write-Output
    $jobs_fail | Format-Table -AutoSize | Out-String | Write-Output
    "--"*20 | Write-Output
}

$jobs_exception = @()
$jobs_exception += $jobs_timedout + $jobs_fail
[System.Collections.ArrayList]$jobErrMessages = @()
if($jobs_exception.Count -gt 0 ) {   
    $alertHost = $jobs_exception | Select-Object -ExpandProperty Name -First 1
    $isCustomError = $true
    $errMessage = "`nBelow jobs either timed or failed-`n$($jobs_exception | Select-Object Name, State, HasErrors | Format-Table -AutoSize | Out-String -Width 700)"
    $failCount = $jobs_fail.Count
    $failCounter = 0
    foreach($job in $jobs_fail) {
        $failCounter += 1
        $jobErrMessage = ''
        if($failCounter -eq 1) {
            $jobErrMessage = "`n$("_"*20)`n" | Write-Output
        }
        $jobErrMessage += "`nError Message for server [$($job.Name)] => `n`n$($job.Error | Out-String)"
        $jobErrMessage += "$("_"*20)`n`n" | Write-Output
        $jobErrMessages.Add($jobErrMessage) | Out-Null;
    }
    $errMessage += ($jobErrMessages -join '')
    #throw $errMessage
}
$jobs | Remove-RSJob -Verbose:$false

#throw $errMessage


# F:\GitHub\SQLMonitor\SQLMonitor\check-instance-availability.ps1 -InventoryServer SQLMonitor -Debug
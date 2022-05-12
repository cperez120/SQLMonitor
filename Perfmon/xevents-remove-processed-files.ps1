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
    $TableName = '[dbo].[resource_consumption_Processed_XEL_Files]'
)

Import-Module dbatools;

Write-Debug "Here at start of function."
$ErrorActionPreference = 'Stop'
$currentTime = Get-Date

"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Get processed xevent files from $Database.$TableName.."

$sqlFiles2Process = @"
select *
from $TableName f
where f.is_removed_from_disk = 0 and is_processed = 1
order by collection_time_utc asc;
"@

$files2Process = @()
$files2Process += Invoke-DbaQuery -SqlInstance $SqlInstance -Database $Database -Query $sqlFiles2Process -EnableException
"$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "$($files2Process.Count) files to process.."

$sqlUpdateFileEntry = "update $Tablename set is_removed_from_disk = 1 where file_path = @file_path"
foreach($row in $files2Process)
{
    $file = $row.file_path
    $fileOnDisk = $file
    if( -not ($HostName -eq $env:COMPUTERNAME -or $HostName -eq 'localhost') ) {
        $fileOnDisk = $("\\$HostName\"+$fileOnDisk.Replace(':','$'))
    }
    if (Test-Path $fileOnDisk) {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Removing '$fileOnDisk' .."
        Remove-Item -Path $fileOnDisk
        if ( -not (Test-Path $fileOnDisk) ) {
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "File removed. Proceeding to  update flag [is_removed_from_disk].."
            Invoke-DbaQuery -SqlInstance $SqlInstance -Database $Database -Query $sqlUpdateFileEntry -SqlParameter @{ file_path = "$file" } -EnableException
            "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Flag updated."
        }
    }
    else {
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "File '$fileOnDisk' not present on disk."
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Proceeding to  update flag [is_removed_from_disk].."
        Invoke-DbaQuery -SqlInstance $SqlInstance -Database $Database -Query $sqlUpdateFileEntry -SqlParameter @{ file_path = "$file" } -EnableException
        "$(Get-Date -Format yyyyMMMdd_HHmm) {0,-10} {1}" -f 'INFO:', "Flag updated."
    }
}




$HostName = 'AllVersion'
$DestinationDrive = 'Y:\'

# Copy Perfmon scripts
Copy-Item -Path '\\SQLShare\S$\Perfmon' -Destination "\\$HostName\$($DestinationDrive.Replace(':','$'))" -Recurse -Container -Force

$ssn = New-PSSession -ComputerName $HostName
Invoke-Command -Session $ssn -ScriptBlock { 
    # Set execution policy
    Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy Unrestricted -Force 
    
    # Create data collector
    & 'Y:\Perfmon\perfmon-collector-logman.ps1' -TemplatePath 'Y:\Perfmon\DBA_PerfMon_All_Counters_Template.xml'
}

$ssn | Remove-PSSession


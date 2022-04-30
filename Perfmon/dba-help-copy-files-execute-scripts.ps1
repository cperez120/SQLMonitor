$HostName = 'SqlPractice'
$DestinationDrive = 'C:\'

# Copy Perfmon scripts
Copy-Item -Path 'F:\GitHub\SqlServer-Baselining-Grafana\Perfmon' -Destination "\\$HostName\$($DestinationDrive.Replace(':','$'))" -Recurse -Container -Force

$ssn = New-PSSession -ComputerName $HostName
Invoke-Command -Session $ssn -ScriptBlock { 
    Param ($Drive)
    # Set execution policy
    Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy Unrestricted -Force 

    #logman stop -name “DBA”
    #logman delete -name “DBA”
    
    # Create data collector
    & "$($Using:DestinationDrive)Perfmon\perfmon-collector-logman.ps1" -TemplatePath "$($Using:DestinationDrive)Perfmon\DBA_PerfMon_All_Counters_Template.xml"
} 

$ssn | Remove-PSSession


#$adCredential = Get-Credential -UserName 'Lab\adwivedi' -Message 'SQL Admin'
#$saCredential = Get-Credential -UserName 'sa' -Message 'sa'
#$localAdmin = Get-Credential -UserName 'DEMO\Administrator' -Message 'Windows Admin'
#Pa$$w0rd
cls
$params = @{
    SqlInstanceToBaseline = 'Demo\SQL2014'
    DbaToolsFolderPath = 'F:\GitHub\dbatools'
    SqlCredential = $saCredential
    WindowsCredential = $localAdmin
    SkipSteps = @('11__CopyPerfmonFolder2Host','12__SetupPerfmonDataCollector','13__CreateJobCollectOSProcesses','14__CreateJobCollectPerfmonData')
    #StartAtStep = '11__CopyPerfmonFolder2Host'
    #StopAtStep = '11__CopyPerfmonFolder2Host'
}
F:\GitHub\SQLMonitor\Perfmon\setup-sqlmonitor-baseline.ps1 @Params

<#

Enable-PSRemoting -Force # run on remote machine
Set-Item WSMAN:\Localhost\Client\TrustedHosts -Value * -Force # run on local machine
#Set-NetConnectionProfile -NetworkCategory Private # Execute this only if above command fails

$ssn = New-PSSession -ComputerName DEMO -Credential $localAdmin -Authentication Negotiate
Test-WSMan DEMO -Credential $localAdmin -Authentication Negotiate

#>
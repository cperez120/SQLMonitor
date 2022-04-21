$ssn = New-PSSession -ComputerName 'SqlProd-A'

# Set execution policy
Invoke-Command -Session $ssn -ScriptBlock { Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy Unrestricted -Force }

# Copy Perfmon scripts
Invoke-Command -Session $ssn -ScriptBlock { 
    Copy-Item -Path '\\SQLShare\S$\Perfmon' -Destination "E:" -Recurse -Container
}

Invoke-Command -Session $ssn -ScriptBlock { 
    & 'E:\Perfmon\perfmon-collector-logman.ps1' 
}

$ssn | Remove-PSSession


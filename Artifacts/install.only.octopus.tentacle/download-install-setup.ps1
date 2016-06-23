#Downloading the tentacle installer
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $url    
)
#$url = "https://download.octopusdeploy.com/octopus/Octopus.Tentacle.3.3.19-x64.msi"
$output = "$PSScriptRoot\tentacle.msi"
$start_time = Get-Date

(New-Object System.Net.WebClient).DownloadFile($url, $output)

Write-Output "Time taken downloading tentacle: $((Get-Date).Subtract($start_time).Seconds) second(s)"

#Install Octopus Tentacle
msiexec /i tentacle.msi /quiet /norestart

#Wait a momento to avoid not found errors
Start-Sleep -s 5

#Change location to installation directory
Set-Location "C:\Program Files\Octopus Deploy\Tentacle"

Write-Host "Everything Ok!."
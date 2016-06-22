#Downloading the tentacle installer

$url = "https://download.octopusdeploy.com/octopus/Octopus.Tentacle.3.3.19-x64.msi"
$output = "$PSScriptRoot\tentacle.msi"
$start_time = Get-Date

(New-Object System.Net.WebClient).DownloadFile($url, $output)

Write-Output "Time taken downloading tentacle: $((Get-Date).Subtract($start_time).Seconds) second(s)"
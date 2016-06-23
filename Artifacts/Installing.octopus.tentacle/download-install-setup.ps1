#Downloading the tentacle installer
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $url,
    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $octopus_server,
        
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $ipAddress,    
    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $environment,
    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $tentacle_role,
    
    [Parameter(Mandatory=$true)]        
    $apiKey,

    [Parameter(Mandatory=$true)]        
    $thumbprint
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

#Create and install the Octopus Tentacle instance 
.\Tentacle.exe create-instance --instance "Tentacle" --config "C:\Octopus\Tentacle.config" --console
.\Tentacle.exe new-certificate --instance "Tentacle" --if-blank --console
.\Tentacle.exe configure --instance "Tentacle" --reset-trust --console
.\Tentacle.exe configure --instance "Tentacle" --home "C:\Octopus" --app "C:\Octopus\Applications" --port "10933" --console
.\Tentacle.exe configure --instance "Tentacle" --trust $thumbprint --console

#"netsh" advfirewall firewall add rule "name=Octopus Deploy Tentacle" dir=in action=allow protocol=TCP localport=10933
Try
{
    New-NetFirewallRule -DisplayName "Octopus Deploy Tentacle" -Action Allow -Direction Inbound -LocalPort 10933 -Protocol TCP
}
Catch
{
    netsh advfirewall firewall add rule name="Octopus Deploy Tentacle" dir=in action=allow protocol=TCP localport=10933
}

#Register the tentacle with the Octopus Server
.\Tentacle.exe register-with --instance "Tentacle" --server $octopus_server --apiKey=$apiKey --role $tentacle_role --environment $environment --publicHostName $ipAddress --comms-style TentaclePassive --console
.\Tentacle.exe service --instance "Tentacle" --install --start --console

Write-Host "The tentacle was successfully installed."

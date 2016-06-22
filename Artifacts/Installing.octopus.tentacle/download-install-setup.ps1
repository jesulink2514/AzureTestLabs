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
    $environment,
    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $tentacle_role,
    
    [Parameter(Mandatory=$true)]        
    $apiKey

    [Parameter(Mandatory=$true)]        
    $thumbprint
)
#$url = "https://download.octopusdeploy.com/octopus/Octopus.Tentacle.3.3.19-x64.msi"
$output = "$PSScriptRoot\tentacle.msi"
$start_time = Get-Date

(New-Object System.Net.WebClient).DownloadFile($url, $output)

Write-Output "Time taken downloading tentacle: $((Get-Date).Subtract($start_time).Seconds) second(s)"

#Install Octopus Tentacle
msiexec /i tentacle.msi /quiet

#Change location to installation directory
cd "C:\Program Files\Octopus Deploy\Tentacle"

#Installing Tentacle and set Thumbprint
#$octopus_server = "http://octopus.com"
#$environment = "Integration"
#$tentacle_role = "web"
#$apiKey = "";
#$thumbprint=""

#Create and install the Octopus Tentacle instance 
Tentacle.exe create-instance --instance "Tentacle" --config "C:\Octopus\Tentacle.config" --console
Tentacle.exe new-certificate --instance "Tentacle" --if-blank --console
Tentacle.exe configure --instance "Tentacle" --reset-trust --console
Tentacle.exe configure --instance "Tentacle" --home "C:\Octopus" --app "C:\Octopus\Applications" --port "10933" --console
Tentacle.exe configure --instance "Tentacle" --trust $thumbprint --console
"netsh" advfirewall firewall add rule "name=Octopus Deploy Tentacle" dir=in action=allow protocol=TCP localport=10933

#Register the tentacle with the Octopus Server
Tentacle.exe register-with --instance "Tentacle" --server $octopus_server --apiKey=$apiKey --role $tentacle_role --environment $environment --comms-style TentaclePassive --console
Tentacle.exe service --instance "Tentacle" --install --start --console

Write-Host "The tentacle was successfully installed."

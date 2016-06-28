#Downloading the tentacle installer
[CmdletBinding()]
Param(   
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $octopus_server,
        
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $ipAddress,

    [Parameter(Mandatory=$true)]        
    [ValidateNotNullOrEmpty()]
    $apiKey,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $environment,
    
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $tentacle_role,    

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $thumbprint
)

#Create and install the Octopus Tentacle instance 
C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe create-instance --instance "Tentacle" --config "C:\Octopus\Tentacle.config" --console
C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe new-certificate --instance "Tentacle" --if-blank --console
C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe configure --instance "Tentacle" --reset-trust --console
C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe configure --instance "Tentacle" --home "C:\Octopus" --app "C:\Octopus\Applications" --port "10933" --console
C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe configure --instance "Tentacle" --trust $thumbprint --console

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
C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe register-with --instance "Tentacle" --server $octopus_server --apiKey=$apiKey --role $tentacle_role --environment $environment --publicHostName $ipAddress --comms-style TentaclePassive --console
C:\Program Files\Octopus Deploy\Tentacle\Tentacle.exe service --instance "Tentacle" --install --start --console

Write-Host "The tentacle was successfully installed."

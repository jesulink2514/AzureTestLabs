[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $username,
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $password,
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
$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential $username, $securePassword

Start-Process powershell.exe -Credential $credential -ExecutionPolicy bypass -File download-install-setup.ps1 $url $octopus_server $environment $tentacle_role $apiKey $thumbprint
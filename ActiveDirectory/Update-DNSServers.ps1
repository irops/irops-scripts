[CmdletBinding()]
param (
    [string]
    [Parameter(Mandatory=$true)]
    $DomainControllerAHostName,

    [string]
    [Parameter(Mandatory=$true)]
    $DomainControllerAPrivateIp,

    [string]
    [Parameter(Mandatory=$true)]
    $Username,

    [string]
    [Parameter(Mandatory=$true)]
    $Password,

    [string]
    [Parameter(Mandatory=$true)]
    $NetBIOSDomain
)

$DomainControllerBPrivateIP = Invoke-RestMethod http://169.254.169.254/latest/meta-data/local-ipv4

# Locally update DomainControllerB DNS Servers
Get-NetAdapter | Set-DnsClientServerAddress -ServerAddresses $DomainControllerBPrivateIp,$DomainControllerAPrivateIp

# Remotely update DomainControllerA DNS Servers
Invoke-Command -Scriptblock { param($DCAIp, $DCBIp) Get-NetAdapter | Set-DnsClientServerAddress -ServerAddresses $DCAIp,$DCBIp } -ArgumentList $DomainControllerAPrivateIp, $DomainControllerBPrivateIp -ComputerName $DomainControllerAHostName -Credential (New-Object System.Management.Automation.PSCredential("$NetBIOSDomain\$Username",(ConvertTo-SecureString "$Password" -AsPlainText -Force)))

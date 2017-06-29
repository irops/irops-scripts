[CmdletBinding()]
param (
    [string]
    [Parameter(Position=0, Mandatory=$false)]
    $DNSServerAddress
)

if (!$DNSServerAddress) {
    $DNSServerAddress = (Get-NetIPConfiguration).DNSServer.ServerAddresses
}

$netip = Get-NetIPConfiguration
$ipconfig = Get-NetIPAddress | ?{$_.IpAddress -eq $netip.IPv4Address.IpAddress}
Get-NetAdapter | Set-NetIPInterface -DHCP Disabled
Get-NetAdapter | New-NetIPAddress -AddressFamily IPv4 -IPAddress $netip.IPv4Address.IpAddress -PrefixLength $ipconfig.PrefixLength -DefaultGateway $netip.IPv4DefaultGateway.NextHop
Get-NetAdapter | Set-DnsClientServerAddress -ServerAddresses $DNSServerAddress

[CmdletBinding()]
param (
    [string]
    [Parameter(Position=0, Mandatory=$true)]
    $ZoneA,

    [string]
    [Parameter(Position=1, Mandatory=$true)]
    $ZoneB,

    [string]
    [Parameter(Position=2, Mandatory=$true)]
    $HostNamePrefix
)

try {
    $ErrorActionPreference = "Stop"

    # Get zone
    $zone = Invoke-RestMethod http://169.254.169.254/latest/meta-data/placement/availability-zone

    # Append HostName Instance and Zone Code
    if ($zone -eq $ZoneA) {
        $hostname = $HostNamePrefix + "01a"
    }
    else {
        $hostname = $HostNamePrefix + "01b"
    }

    # Associate Public Address
    Rename-Computer -NewName $hostname -Restart
}
catch {
    Write-Verbose "$($_.exception.message)@ $(Get-Date)"
    $_ | Write-AWSQuickStartException
}

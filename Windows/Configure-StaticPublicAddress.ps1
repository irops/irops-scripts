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
    $EIPAllocationA,

    [string]
    [Parameter(Position=3, Mandatory=$false)]
    $EIPAllocationB
)

try {
    $ErrorActionPreference = "Stop"

    # Get zone and region
    $zone = Invoke-RestMethod http://169.254.169.254/latest/meta-data/placement/availability-zone
    $region = $zone -replace ".$"

    # Get instance
    $instance = Invoke-RestMethod http://169.254.169.254/latest/meta-data/instance-id

    # Choose EIP Allocation
    if ($zone -eq $ZoneA) {
        $allocation = $EIPAllocationA
    }
    else {
        $allocation = $EIPAllocationB
    }

    # Associate Public Address
    $association = Register-EC2Address -AllocationId $allocation -InstanceId $instance -Region $region
}
catch {
    Write-Verbose "$($_.exception.message)@ $(Get-Date)"
    $_ | Write-AWSQuickStartException
}

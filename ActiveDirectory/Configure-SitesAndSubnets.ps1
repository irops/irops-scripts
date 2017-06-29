[CmdletBinding()]
param (
    [string]
    [Parameter(Position=0, Mandatory=$true)]
    $VpcId,

    [string]
    [Parameter(Position=1, Mandatory=$true)]
    $ZoneA,

    [string]
    [Parameter(Position=2, Mandatory=$true)]
    $ZoneB,

    [switch]
    $MultiZone
)

try {
    Write-Verbose "Renaming default Site to ZoneA"
    Get-ADObject -SearchBase (Get-ADRootDSE).ConfigurationNamingContext -filter {Name -eq 'Default-First-Site-Name'} | Rename-ADObject -NewName ZoneA
}
catch {
    Write-Host "Error renaming default Site to ZoneA"
}

if ($MultiZone) {
    try {
        Write-Verbose "Creating new Site for ZoneB"
        New-ADReplicationSite ZoneB
    }
    catch {
        Write-Host "Error creating new Site for ZoneB"
    }
}

try {
    Write-Verbose "Obtaining Region"
    $region = (Invoke-RestMethod http://169.254.169.254/latest/dynamic/instance-identity/document).region

    Write-Verbose "Adding ZoneA Subnets to ZoneA Site"
    Get-EC2Subnet -Filter @( @{Name = 'vpc-id'; Values = $VpcId}; @{Name = 'availabilityZone'; Values = $ZoneA} ) |
    Select-Object CidrBlock, @{Name="Description";Expression={$_.tags | where key -eq "Name" | select Value -expand Value}} |
    ForEach-Object { New-ADReplicationSubnet -Name $_.CidrBlock -Description $_.Description -Location $region -Site ZoneA }

    if ($MultiZone) {
        Write-Verbose "Adding ZoneB Subnets to ZoneB Site"
        Get-EC2Subnet -Filter @( @{Name = 'vpc-id'; Values = $VpcId}; @{Name = 'availabilityZone'; Values = $ZoneB} ) |
        Select-Object CidrBlock, @{Name="Description";Expression={$_.tags | where key -eq "Name" | select Value -expand Value}} |
        ForEach-Object { New-ADReplicationSubnet -Name $_.CidrBlock -Description $_.Description -Location $region -Site ZoneB }
    }
    else {
        Write-Verbose "Adding ZoneB Subnets to ZoneA Site"
        Get-EC2Subnet -Filter @( @{Name = 'vpc-id'; Values = $VpcId}; @{Name = 'availabilityZone'; Values = $ZoneB} ) |
        Select-Object CidrBlock, @{Name="Description";Expression={$_.tags | where key -eq "Name" | select Value -expand Value}} |
        ForEach-Object { New-ADReplicationSubnet -Name $_.CidrBlock -Description $_.Description -Location $region -Site ZoneA }
    }
}
catch {
    Write-Host "Error configuring Subnets"
}

if ($MultiZone) {
    try {
        Write-Verbose "Renaming default SiteLink to ZoneA-ZoneB"
        Get-ADObject -SearchBase (Get-ADRootDSE).ConfigurationNamingContext -filter {Name -eq 'DEFAULTIPSITELINK'} | Rename-ADObject -NewName 'ZoneA-ZoneB'

        Write-Verbose "Configuring SiteLink"
        Get-ADReplicationSiteLink -Filter {SitesIncluded -eq "ZoneA"} | Set-ADReplicationSiteLink -SitesIncluded @{add='ZoneB'} -ReplicationFrequencyInMinutes 15 -Replace @{'options'=1}
    }
    catch {
        Write-Host "Error configuring SiteLink"
    }
}

#
# Configures the specified user's PowerShell profile
# - Located here:
#   C:\Users\$User\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
#

[CmdletBinding()]
param (
    [string]
    [Parameter(Position=0, Mandatory=$true)]
    $User
)

New-Item C:\Users\$User\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 -ItemType file -Force

@'
Set-Location C:\

$Shell = $Host.UI.RawUI

$size = $Shell.WindowSize
$size.width=120
$size.height=32
$Shell.WindowSize = $size

$size = $Shell.BufferSize
$size.width=120
$size.height=2000
$Shell.BufferSize = $size

$Shell.BackgroundColor = ($background = 'White')
$Shell.ForegroundColor = ($foreground = 'Black')
$Host.PrivateData.ErrorForegroundColor = 'Red'
$Host.PrivateData.ErrorBackgroundColor = $background
$Host.PrivateData.WarningForegroundColor = 'Magenta'
$Host.PrivateData.WarningBackgroundColor = $background
$Host.PrivateData.DebugForegroundColor = 'Blue'
$Host.PrivateData.DebugBackgroundColor = $background
$Host.PrivateData.VerboseForegroundColor = 'DarkGreen'
$Host.PrivateData.VerboseBackgroundColor = $background
$Host.PrivateData.ProgressForegroundColor = 'DarkCyan'
$Host.PrivateData.ProgressBackgroundColor = $background

Clear-Host
'@ | Out-File -FilePath C:\Users\$User\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 -Append -Encoding ASCII

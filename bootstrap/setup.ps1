$ErrorActionPreference = "Stop"

. "$PSScriptRoot\modules\loader.ps1"

$config = Get-BootstrapConfig

Start-Setup

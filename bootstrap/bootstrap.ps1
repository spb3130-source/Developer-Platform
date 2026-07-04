$ErrorActionPreference = "Stop"

. "$PSScriptRoot\modules\loader.ps1"

$config = Get-BootstrapConfig

Write-Step "$($config.project.name) Bootstrap"

Invoke-Step "Development Environment Validation" {

    foreach ($tool in $config.tools) {

        Test-Tool $tool.name $tool.command

    }

}

Invoke-Step "Git Installation" {

    Install-Git

}

Write-Success "Bootstrap Complete."

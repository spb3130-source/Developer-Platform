$ErrorActionPreference = "Stop"

. "$PSScriptRoot\modules\core.ps1"
. "$PSScriptRoot\modules\validation.ps1"

$config = Get-Content "$PSScriptRoot\config\bootstrap.json" | ConvertFrom-Json

Write-Step "$($config.project.name) Bootstrap"

Invoke-Step "Development Environment Validation" {

    foreach ($tool in $config.tools) {

        Test-Tool $tool.name $tool.command

    }

}

Write-Success "Bootstrap Complete."

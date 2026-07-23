function Install-GitHubCLI {

    $gh = Get-Command gh -ErrorAction SilentlyContinue

    if ($gh) {

        Write-Success "GitHub CLI is already installed. Skipping installation."

        return

    }

    $winget = Get-Command winget -ErrorAction SilentlyContinue

    if (-not $winget) {

        throw "Winget is required to install GitHub CLI."

    }

    Write-Step "Installing GitHub CLI via Winget"

    winget install --id GitHub.cli `
        --exact `
        --accept-package-agreements `
        --accept-source-agreements `
        --silent

    if ($LASTEXITCODE -ne 0) {

        throw "Winget failed to install GitHub CLI (exit code $LASTEXITCODE)."

    }

    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")

    $env:Path = "$machinePath;$userPath"

    Write-Success "GitHub CLI installation completed."

}

function Verify-GitHubCLI {

    $gh = Get-Command gh -ErrorAction SilentlyContinue

    if (-not $gh) {

        Write-WarningMessage "GitHub CLI is not installed or not available in PATH."

        return $false

    }

    $version = gh --version | Select-Object -First 1

    Write-Success "GitHub CLI Verified - $version"

    return $true

}

function Configure-GitHubCLI {

    Write-Step "Configure GitHub CLI"

    $status = gh auth status 2>&1

    if ($LASTEXITCODE -eq 0) {

        Write-Success "GitHub CLI is already authenticated."

        return

    }

    Write-WarningMessage "GitHub CLI is not authenticated."

    Write-WarningMessage "Run 'gh auth login' to authenticate."

}

function Test-GitHubCLI {

    Write-Step "GitHub CLI Workflow Validation"

    $status = gh auth status 2>&1

    if ($LASTEXITCODE -eq 0) {

        Write-Success "Authentication status verified."

    }
    else {

        Write-WarningMessage "Authentication not configured."

    }

    $version = gh --version | Select-Object -First 1

    Write-Success "GitHub CLI version: $version"

    Write-Success "GitHub CLI workflow validation finished."

}

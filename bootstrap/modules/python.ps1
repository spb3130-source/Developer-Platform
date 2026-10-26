
function Install-Python {

    $python = Get-Command python -ErrorAction SilentlyContinue

    if ($python) {

        Write-Success "Python is already available. Skipping installation."

        return

    }

    $winget = Get-Command winget -ErrorAction SilentlyContinue

    if (-not $winget) {

        throw "Winget is required to install Python but is not available."

    }

    Write-Step "Installing Python via Winget"

    winget install --id Python.Python.3.13 `
        --exact `
        --accept-package-agreements `
        --accept-source-agreements `
        --silent

    if ($LASTEXITCODE -ne 0) {

        throw "Winget failed to install Python (exit code $LASTEXITCODE)."

    }

    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")

    $env:Path = "$machinePath;$userPath"

    Write-Success "Python installation command completed."

}

function Verify-Python {

    $python = Get-Command python -ErrorAction SilentlyContinue

    if (-not $python) {

        throw "Python is not available in PATH."

    }

    $versionOutput = & python --version 2>&1

    if ($LASTEXITCODE -ne 0) {

        throw "Python version verification failed: $versionOutput"

    }

    $version = ($versionOutput | Out-String).Trim()

    Write-Success "Python Verified - $version"

    $pipOutput = & python -m pip --version 2>&1

    if ($LASTEXITCODE -ne 0) {

        throw "pip is not available or verification failed: $pipOutput"

    }

    $pipVersion = ($pipOutput | Out-String).Trim()

    Write-Success "pip Verified - $pipVersion"

    return $true

}

function Configure-Python {

    Write-Step "Configure Python"

    $pip = & python -m pip --version 2>&1

    if ($LASTEXITCODE -ne 0) {

        throw "Cannot configure Python because pip is unavailable: $pip"

    }

    Write-Success "Python and pip are ready. No additional configuration required."

}

function Test-Python {

    Write-Step "Python Workflow Validation"

    $output = & python -c "print('Python workflow validation passed.')" 2>&1

    if ($LASTEXITCODE -ne 0) {

        throw "Python execution test failed: $output"

    }

    Write-Success ($output | Out-String).Trim()

    $pipOutput = & python -m pip list --format=columns 2>&1

    if ($LASTEXITCODE -ne 0) {

        throw "pip workflow validation failed: $pipOutput"

    }

    Write-Success "pip package listing succeeded."

    Write-Success "Python workflow validation finished."

}

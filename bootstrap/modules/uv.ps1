
function Install-Uv {
    $uv = Get-Command uv -ErrorAction SilentlyContinue
    if ($uv) {
        Write-Success "uv is already available. Skipping installation."
        return
    }

    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if (-not $winget) {
        throw "Winget is required to install uv but is not available."
    }

    Write-Step "Installing uv via Winget"

    winget install --id astral-sh.uv `
        --exact `
        --accept-package-agreements `
        --accept-source-agreements `
        --silent

    if ($LASTEXITCODE -ne 0) {
        throw "Winget failed to install uv (exit code $LASTEXITCODE)."
    }

    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machinePath;$userPath"

    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        throw "uv installation completed, but uv is not available in the current PATH. Open a new terminal and retry."
    }

    Write-Success "uv installation completed."
}

function Verify-Uv {
    $uv = Get-Command uv -ErrorAction SilentlyContinue
    if (-not $uv) {
        throw "uv is not available in PATH."
    }

    $versionOutput = & uv --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "uv version verification failed: $versionOutput"
    }

    $version = ($versionOutput | Out-String).Trim()
    Write-Success "uv Verified - $version"

    return $true
}

function Configure-Uv {
    Write-Step "Configure uv"

    $pythonOutput = & uv python find 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "uv could not locate a Python interpreter: $pythonOutput"
    }

    Write-Success "uv can locate a Python interpreter."
}

function Test-Uv {
    Write-Step "uv Workflow Validation"

    $versionOutput = & uv --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "uv execution test failed: $versionOutput"
    }

    Write-Success "uv execution test passed."

    $pythonOutput = & uv python find 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "uv Python discovery test failed: $pythonOutput"
    }

    Write-Success "uv Python discovery passed."
    Write-Success "uv workflow validation finished."
}


function Install-Node {
    $node = Get-Command node -ErrorAction SilentlyContinue

    if ($node) {
        Write-Success "Node.js is already available. Skipping installation."
    }
    else {
        $winget = Get-Command winget -ErrorAction SilentlyContinue
        if (-not $winget) {
            throw "Winget is required to install Node.js but is not available."
        }

        Write-Step "Installing Node.js LTS via Winget"

        winget install --id OpenJS.NodeJS.LTS `
            --exact `
            --accept-package-agreements `
            --accept-source-agreements `
            --silent

        if ($LASTEXITCODE -ne 0) {
            throw "Winget failed to install Node.js (exit code $LASTEXITCODE)."
        }

        $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
        $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
        $env:Path = "$machinePath;$userPath"

        if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
            throw "Node.js installation completed, but node is not available in PATH. Open a new terminal and retry."
        }

        Write-Success "Node.js installation completed."
    }

    $npm = Get-Command npm -ErrorAction SilentlyContinue
    if (-not $npm) {
        throw "npm is not available. Verify the Node.js installation before continuing."
    }

    Write-Success "npm is available."
}

function Verify-Node {
    $node = Get-Command node -ErrorAction SilentlyContinue
    if (-not $node) {
        throw "Node.js is not available in PATH."
    }

    $nodeVersion = & node --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Node.js version verification failed: $nodeVersion"
    }

    Write-Success "Node.js Verified - $(($nodeVersion | Out-String).Trim())"

    $npmVersion = & npm --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "npm version verification failed: $npmVersion"
    }

    Write-Success "npm Verified - $(($npmVersion | Out-String).Trim())"

    return $true
}

function Install-Pnpm {
    $pnpm = Get-Command pnpm -ErrorAction SilentlyContinue

    if ($pnpm) {
        Write-Success "pnpm is already available. Skipping installation."
        return
    }

    $corepack = Get-Command corepack -ErrorAction SilentlyContinue
    if ($corepack) {
        Write-Step "Enabling pnpm through Corepack"

        & corepack enable
        if ($LASTEXITCODE -ne 0) {
            throw "Corepack could not be enabled (exit code $LASTEXITCODE)."
        }

        & corepack prepare pnpm@latest --activate
        if ($LASTEXITCODE -eq 0) {
            $env:Path = "$env:APPDATA\npm;$env:Path"

            if (Get-Command pnpm -ErrorAction SilentlyContinue) {
                Write-Success "pnpm enabled through Corepack."
                return
            }
        }

        Write-WarningMessage "Corepack did not make pnpm available. Trying npm installation."
    }

    Write-Step "Installing pnpm through npm"

    & npm install --global pnpm
    if ($LASTEXITCODE -ne 0) {
        throw "npm failed to install pnpm (exit code $LASTEXITCODE)."
    }

    $env:Path = "$env:APPDATA\npm;$env:Path"

    if (-not (Get-Command pnpm -ErrorAction SilentlyContinue)) {
        throw "pnpm installation completed, but pnpm is not available in PATH. Open a new terminal and retry."
    }

    Write-Success "pnpm installation completed."
}

function Verify-Pnpm {
    $pnpm = Get-Command pnpm -ErrorAction SilentlyContinue
    if (-not $pnpm) {
        throw "pnpm is not available in PATH."
    }

    $versionOutput = & pnpm --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "pnpm version verification failed: $versionOutput"
    }

    Write-Success "pnpm Verified - $(($versionOutput | Out-String).Trim())"

    return $true
}

function Configure-Node {
    Write-Step "Configure Node.js and pnpm"

    $nodeVersion = & node --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Node.js is unavailable during configuration."
    }

    $npmVersion = & npm --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "npm is unavailable during configuration."
    }

    Write-Success "Node.js and npm are ready. No additional configuration required."
}

function Test-Node {
    Write-Step "Node.js Workflow Validation"

    $nodeOutput = & node -e "console.log('Node.js workflow validation passed.')" 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Node.js execution test failed: $nodeOutput"
    }

    Write-Success ($nodeOutput | Out-String).Trim()

    $npmOutput = & npm --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "npm workflow validation failed: $npmOutput"
    }

    Write-Success "npm workflow validation passed."

    $pnpmOutput = & pnpm --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "pnpm workflow validation failed: $pnpmOutput"
    }

    Write-Success "pnpm workflow validation passed."
    Write-Success "Node.js workflow validation finished."
}

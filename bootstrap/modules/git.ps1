
function Install-Git {

    $git = Get-Command git -ErrorAction SilentlyContinue

    if ($git) {

        Write-Success "Git is already installed. Skipping installation."

        return

    }

    $winget = Get-Command winget -ErrorAction SilentlyContinue

    if (-not $winget) {

        throw "Winget is required to install Git."

    }

    Write-Step "Installing Git via Winget"

    winget install --id Git.Git `
        --exact `
        --accept-package-agreements `
        --accept-source-agreements `
        --silent

    if ($LASTEXITCODE -ne 0) {

        throw "Winget failed to install Git (exit code $LASTEXITCODE)."

    }

    $machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $userPath    = [Environment]::GetEnvironmentVariable("Path", "User")

    $env:Path = "$machinePath;$userPath"

    Write-Success "Git installation completed."

}

function Verify-Git {

    $git = Get-Command git -ErrorAction SilentlyContinue

    if (-not $git) {

        Write-WarningMessage "Git is not installed or not available in PATH."

        return $false

    }

    $version = git --version

    Write-Success "Git Verified - $version"

    return $true

}

function Configure-Git {

    Write-Step "Configure Git"

    $response = Read-Host "Do you want to configure basic Git global settings? (y/N)"

    if ($response -notin @("y", "Y", "yes", "Yes")) {

        Write-WarningMessage "Skipping Git configuration."

        return

    }

    $existingName = git config --global user.name

    $defaultName = $existingName

    if ([string]::IsNullOrWhiteSpace($defaultName)) {

        $defaultName = $env:USERNAME

    }

    $name = Read-Host "Git user.name [$defaultName]"

    if ([string]::IsNullOrWhiteSpace($name)) {

        $name = $defaultName

    }

    $existingEmail = git config --global user.email

    $defaultEmail = $existingEmail

    if ([string]::IsNullOrWhiteSpace($defaultEmail)) {

        $defaultEmail = "$env:USERNAME@localhost.localdomain"

    }

    $email = Read-Host "Git user.email [$defaultEmail]"

    if ([string]::IsNullOrWhiteSpace($email)) {

        $email = $defaultEmail

    }

    git config --global user.name "$name"

    git config --global user.email "$email"

    git config --global init.defaultBranch "main"

    git config --global core.autocrlf "true"

    git config --global push.autoSetupRemote "true"

    Write-Success "Git configuration completed."

}

function Test-GitWorkflow {

    Write-Step "Git Workflow Validation"

    $name = git config --global user.name

    $email = git config --global user.email

    $defaultBranch = git config --global init.defaultBranch

    $autocrlf = git config --global core.autocrlf

    $autoSetupRemote = git config --global push.autoSetupRemote

    if ([string]::IsNullOrWhiteSpace($autoSetupRemote)) {

        $autoSetupRemote = "<Not Configured>"

    }

    Write-Success "Git config: user.name=$name"

    Write-Success "Git config: user.email=$email"

    Write-Success "Git config: init.defaultBranch=$defaultBranch"

    Write-Success "Git config: core.autocrlf=$autocrlf"

    Write-Success "Git config: push.autoSetupRemote=$autoSetupRemote"

    $testRepo = Join-Path -Path $env:TEMP -ChildPath ("git-workflow-validation-" + [Guid]::NewGuid().ToString())

    Push-Location

    try {

        New-Item -ItemType Directory -Path $testRepo -Force | Out-Null

        Set-Location -Path $testRepo

        $initOutput = git init 2>&1

        Write-Success "Git init succeeded: $initOutput"

        "workflow-validation" | Set-Content -Path "workflow-validation.txt" -NoNewline

        git add workflow-validation.txt | Out-Null

        Write-Success "Git add succeeded."

        if ([string]::IsNullOrWhiteSpace($name) -or [string]::IsNullOrWhiteSpace($email)) {

            Write-WarningMessage "Skipping git commit validation because user.name and/or user.email are not configured."

        }
        else {

            $commitOutput = git commit -m "Git workflow validation commit" 2>&1

            if ($LASTEXITCODE -ne 0) {

                Write-WarningMessage "Git commit validation failed: $commitOutput"

            }
            else {

                Write-Success "Git commit succeeded: $commitOutput"

            }

        }

    }
    finally {

        Pop-Location

        Remove-Item -Path $testRepo -Recurse -Force -ErrorAction SilentlyContinue

    }

    Write-Success "Complete Git workflow validation finished."

}

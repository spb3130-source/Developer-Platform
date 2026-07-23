function Start-Setup {

    Write-Step "Developer Platform Setup"

    Initialize-Setup

    Invoke-Setup

    Complete-Setup

}

function Initialize-Setup {

    Write-Success "Setup initialized."

}

function Invoke-Setup {

    Invoke-SetupStep "Framework Validation" {

        Write-Success "Setup pipeline ready."

    }

    Invoke-SetupStep "Winget" {

        Install-Winget

        Configure-Winget

    }

    Invoke-SetupStep "Git" {

        Install-Git

        [void](Verify-Git)

        Configure-Git

        Test-GitWorkflow

    }

    Invoke-SetupStep "GitHub CLI" {

        Install-GitHubCLI

        [void](Verify-GitHubCLI)

        Configure-GitHubCLI

        Test-GitHubCLI

    }

}

function Complete-Setup {

    Write-Step "Setup Complete"

}

function Invoke-SetupStep {

    param(
        [string]$Name,
        [scriptblock]$Action
    )

    Write-Step $Name

    try {

        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

        & $Action

        $stopwatch.Stop()

        Write-Success "$Name completed in $($stopwatch.Elapsed.TotalSeconds.ToString('0.00')) sec."

    }
    catch {

        Write-ErrorMessage $_

        throw

    }

}

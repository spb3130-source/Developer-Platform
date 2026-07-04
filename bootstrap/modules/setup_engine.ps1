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

        & $Action

        Write-Success "$Name completed."

    }
    catch {

        Write-ErrorMessage $_

        throw

    }

}

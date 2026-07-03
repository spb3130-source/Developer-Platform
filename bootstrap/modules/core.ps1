function Write-Step {
    param(
        [string]$Message
    )

    Write-Host ""
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
}

function Write-Success {
    param(
        [string]$Message
    )

    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-WarningMessage {
    param(
        [string]$Message
    )

    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-ErrorMessage {
    param(
        [string]$Message
    )

    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Invoke-Step {

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

    }

}

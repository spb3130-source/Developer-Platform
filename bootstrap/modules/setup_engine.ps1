
function Start-Setup {
    Write-Step "Developer Platform Setup"

    Initialize-Setup

    try {
        Invoke-Setup
        Complete-Setup
    }
    catch {
        $global:DeveloperPlatformSetupState.FailureMessage = $_.Exception.Message
        Complete-Setup -Failed
        throw
    }
}

function Initialize-Setup {
    $global:DeveloperPlatformSetupState = @{
        StartTime      = Get-Date
        EndTime        = $null
        Status         = "Running"
        FailureMessage = $null
        Results        = [System.Collections.Generic.List[object]]::new()
    }

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

    Invoke-SetupStep "Python" {

        Install-Python

        [void](Verify-Python)

        Configure-Python

        Test-Python

    }

    Invoke-SetupStep "uv" {

        Install-Uv

        [void](Verify-Uv)

        Configure-Uv

        Test-Uv
    }


    Invoke-SetupStep "Node.js and pnpm" {
        Install-Node
        [void](Verify-Node)
        Install-Pnpm
        [void](Verify-Pnpm)
        Configure-Node
        Test-Node
    }


    Invoke-SetupStep "Playwright" {
        Install-Playwright
        [void](Verify-Playwright)
        Configure-Playwright
        Test-Playwright
    }


}
function Complete-Setup {
    param(
        [switch]$Failed
    )

    $state = $global:DeveloperPlatformSetupState
    $state.EndTime = Get-Date

    if ($Failed) {
        $state.Status = "Failed"
    }
    else {
        $state.Status = "Passed"
    }

    $duration = ($state.EndTime - $state.StartTime).TotalSeconds
    $passedCount = @($state.Results | Where-Object Status -eq "Passed").Count
    $failedCount = @($state.Results | Where-Object Status -eq "Failed").Count

    Write-Step "Setup Summary"
    Write-Host "Status:   $($state.Status)"
    Write-Host "Passed:   $passedCount"
    Write-Host "Failed:   $failedCount"
    Write-Host "Duration: $([math]::Round($duration, 2)) seconds"

    foreach ($result in $state.Results) {
        $line = "[$($result.Status)] $($result.Name) - $($result.Duration) sec"
        Write-Host $line
    }

    if ($state.FailureMessage) {
        Write-Host "Failure: $($state.FailureMessage)"
    }

    try {
        $reportDirectory = Join-Path (Split-Path $PSScriptRoot -Parent) "reports"
        New-Item -ItemType Directory -Path $reportDirectory -Force | Out-Null

        $reportPath = Join-Path $reportDirectory "setup-report-latest.txt"

        $reportLines = @(
            "Developer Platform Setup Report"
            "Status: $($state.Status)"
            "Started: $($state.StartTime)"
            "Finished: $($state.EndTime)"
            "Duration: $([math]::Round($duration, 2)) seconds"
            "Passed steps: $passedCount"
            "Failed steps: $failedCount"
            ""
            "Step Results:"
        )

        foreach ($result in $state.Results) {
            $reportLines += "[$($result.Status)] $($result.Name) - $($result.Duration) sec"

            if ($result.Error) {
                $reportLines += "  Error: $($result.Error)"
            }
        }

        if ($state.FailureMessage) {
            $reportLines += ""
            $reportLines += "Failure message: $($state.FailureMessage)"
        }

        Set-Content -Path $reportPath -Value $reportLines -Encoding UTF8
        Write-Success "Setup report saved to: $reportPath"
    }
    catch {
        Write-WarningMessage "Could not save setup report: $($_.Exception.Message)"
    }

    if ($Failed) {
        Write-ErrorMessage "Setup failed. Review the failed step and setup report."
    }
    else {
        Write-Success "Setup Complete"
    }
}



function Invoke-SetupStep {
    param(
        [string]$Name,
        [scriptblock]$Action
    )

    Write-Step $Name
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

    try {
        & $Action
        $stopwatch.Stop()

        $global:DeveloperPlatformSetupState.Results.Add([PSCustomObject]@{
                Name     = $Name
                Status   = "Passed"
                Duration = [math]::Round($stopwatch.Elapsed.TotalSeconds, 2)
                Error    = ""
            })

        Write-Success "$Name completed in $($stopwatch.Elapsed.TotalSeconds.ToString('0.00')) sec."
    }
    catch {
        $stopwatch.Stop()
        $errorMessage = $_.Exception.Message

        $global:DeveloperPlatformSetupState.Results.Add([PSCustomObject]@{
                Name     = $Name
                Status   = "Failed"
                Duration = [math]::Round($stopwatch.Elapsed.TotalSeconds, 2)
                Error    = $errorMessage
            })

        Write-ErrorMessage $_
        throw
    }
}

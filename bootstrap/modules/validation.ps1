function Test-Tool {

    param(
        [string]$Name,
        [string]$Command
    )

    $tool = Get-Command $Command -ErrorAction SilentlyContinue

    if ($tool) {

        try {

            $version = (& $Command --version | Select-Object -First 1)

        }
        catch {

            $version = "Version unavailable"

        }

        Write-Success "$Name Installed - $version"

        return $true

    }

    Write-WarningMessage "$Name Not Installed"

    return $false

}

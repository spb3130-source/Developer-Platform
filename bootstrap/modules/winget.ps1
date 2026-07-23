function Install-Winget {

    if (Verify-Winget) {

        Write-Success "Winget already available."

        return

    }

    Write-WarningMessage "Automatic Winget installation is not implemented."

}

function Verify-Winget {

    $winget = Get-Command winget -ErrorAction SilentlyContinue

    if ($winget) {

        $version = (winget --version)

        Write-Success "Winget Installed - $version"

        return $true

    }

    Write-WarningMessage "Winget Not Installed"

    return $false

}

function Configure-Winget {

    Write-Success "No Winget configuration required."

}

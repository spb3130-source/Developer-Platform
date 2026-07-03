function Install-Python {

    if (Test-Command "python") {

        Write-Success "Python already installed."

        return

    }

    Write-WarningMessage "Python installation will be implemented in Sprint 3."

}

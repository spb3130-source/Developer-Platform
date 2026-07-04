function Install-Git {

    if (Test-Tool "Git" "git") {

        return

    }

    Write-Step "Installing Git..."

    winget install --id Git.Git `
        --exact `
        --accept-package-agreements `
        --accept-source-agreements

}

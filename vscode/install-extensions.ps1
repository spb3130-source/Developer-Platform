$extensions = @(
    "ms-python.python",
    "ms-python.vscode-pylance",
    "ms-python.debugpy",

    "charliermarsh.ruff",

    "eamodio.gitlens",

    "usernamehw.errorlens",

    "aaron-bond.better-comments",

    "PKief.material-icon-theme",

    "qwtel.sqlite-viewer",

    "esbenp.prettier-vscode",

    "dbaeumer.vscode-eslint",

    "ms-vscode.live-server",

    "formulahendry.auto-rename-tag",

    "christian-kohler.path-intellisense"
)

foreach ($ext in $extensions)
{
    Write-Host ""
    Write-Host "Installing $ext ..."
    code --install-extension $ext --force
}

Write-Host ""
Write-Host "======================================="
Write-Host "All VS Code extensions installed."
Write-Host "======================================="
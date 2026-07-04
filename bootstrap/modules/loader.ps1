$modules = @(
    "core.ps1",
    "validation.ps1",
    "setup_engine.ps1",
    "git.ps1",
    "github.ps1",
    "node.ps1",
    "playwright.ps1",
    "python.ps1",
    "uv.ps1",
    "vscode.ps1",
    "winget.ps1"
)

foreach ($module in $modules) {

    . "$PSScriptRoot\$module"

}

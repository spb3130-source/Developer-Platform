$modules = @(
    "core.ps1",
    "validation.ps1",
    "git.ps1"
)

foreach ($module in $modules) {

    . "$PSScriptRoot\$module"

}

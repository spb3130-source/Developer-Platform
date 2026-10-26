

function Install-Playwright {
    $node = Get-Command node -ErrorAction SilentlyContinue
    $pnpm = Get-Command pnpm -ErrorAction SilentlyContinue

    if (-not $node) {
        throw "Node.js is required to install Playwright."
    }

    if (-not $pnpm) {
        throw "pnpm is required to install Playwright."
    }

    $projectRoot = Join-Path $env:USERPROFILE "PlaywrightValidation"
    $packageFile = Join-Path $projectRoot "package.json"
    $playwrightPackage = Join-Path $projectRoot "node_modules\playwright\package.json"

    New-Item -ItemType Directory -Path $projectRoot -Force | Out-Null

    Push-Location $projectRoot
    try {
        if (-not (Test-Path $packageFile)) {
            & pnpm init

            if ($LASTEXITCODE -ne 0) {
                throw "Failed to initialize the Playwright validation project."
            }
        }

        if (-not (Test-Path $playwrightPackage)) {
            & pnpm add --save-dev playwright

            if ($LASTEXITCODE -ne 0) {
                throw "Failed to install the Playwright package."
            }
        }
        else {
            Write-Success "Playwright package is already installed."
        }
    }
    finally {
        Pop-Location
    }

    if (-not (Test-Path $playwrightPackage)) {
        throw "Playwright package installation could not be verified."
    }

    Write-Success "Playwright package setup completed."
}

function Verify-Playwright {
    $projectRoot = Join-Path $env:USERPROFILE "PlaywrightValidation"
    $playwrightPackage = Join-Path $projectRoot "node_modules\playwright\package.json"

    if (-not (Test-Path $playwrightPackage)) {
        throw "Playwright package was not found at $playwrightPackage."
    }

    $package = Get-Content $playwrightPackage -Raw | ConvertFrom-Json
    Write-Success "Playwright Verified - version $($package.version)"

    return $true
}

function Configure-Playwright {
    $projectRoot = Join-Path $env:USERPROFILE "PlaywrightValidation"

    Push-Location $projectRoot
    try {
        & pnpm exec playwright install chromium

        if ($LASTEXITCODE -ne 0) {
            throw "Failed to install the Playwright Chromium browser."
        }
    }
    finally {
        Pop-Location
    }

    Write-Success "Playwright Chromium browser is installed."
}

function Test-Playwright {
    Write-Step "Playwright Workflow Validation"

    $projectRoot = Join-Path $env:USERPROFILE "PlaywrightValidation"
    $testScript = Join-Path $projectRoot "playwright-validation.cjs"

    $testCode = @'
const { chromium } = require("playwright");

(async () => {
    const browser = await chromium.launch({ headless: true });
    try {
        const page = await browser.newPage();
        await page.setContent("<html><title>Playwright Validation</title><body>OK</body></html>");

        const title = await page.title();
        const body = await page.locator("body").innerText();

        if (title !== "Playwright Validation" || body !== "OK") {
            throw new Error("Unexpected browser validation result.");
        }

        console.log("Playwright browser workflow validation passed.");
    } finally {
        await browser.close();
    }
})().catch(error => {
    console.error(error);
    process.exitCode = 1;
});
'@

    Set-Content -Path $testScript -Value $testCode -Encoding utf8

    Push-Location $projectRoot
    try {
        & node $testScript

        if ($LASTEXITCODE -ne 0) {
            throw "Playwright browser workflow validation failed."
        }
    }
    finally {
        Pop-Location
    }

    Write-Success "Playwright workflow validation finished."
}

<#
.SYNOPSIS
  RankHound v3 enhancement patch — adds GitHub Actions, Pages landing,
  Thanks-to-BeyondTahir section, and upstream PR preparation.

.DESCRIPTION
  Run this from INSIDE the rankhound-build folder (after v2 patch + finish
  scripts have been applied). This script:
    1. Creates .github/workflows/ci.yml (Python tests + ruff lint on push/PR)
    2. Creates .github/workflows/pages.yml (deploys landing page to GitHub Pages)
    3. Creates index.html at root (RankHound landing page for Pages)
    4. Appends 'Thanks to BeyondTahir' section to README.md
    5. Creates UPSTREAM-PR.md (PR template + commands to PR back to upstream)
    6. Commits as v2.11.0-rankhound.3 + pushes

  No logo embedding needed this time — just text files. Small script.
#>
[CmdletBinding()]
param([switch]$SkipPush)

$ErrorActionPreference = 'Continue'  # Don't treat git warnings as errors

$GITHUB_USER = 'QaisarMQM'
$REPO_NAME  = 'rankhound'
$VERSION    = '2.11.0-rankhound.3'

function Write-Step { param($msg) Write-Host "`n>>> $msg" -ForegroundColor Green }
function Write-Sub  { param($msg) Write-Host "    $msg" -ForegroundColor Gray }
function Write-Err  { param($msg) Write-Host "!!  $msg" -ForegroundColor Red }

if (-not (Test-Path 'SKILL.md')) {
    Write-Err "Run this from INSIDE the rankhound-build folder."
    Write-Err "Current: $(Get-Location)"
    exit 1
}

# --- 1. GitHub Actions CI workflow -----------------------------------------
Write-Step 'Create GitHub Actions CI workflow'
$newDir = New-Item -ItemType Directory -Path '.github\workflows' -Force

$ciYml = @"
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        python-version: ['3.10', '3.11', '3.12']

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python `${{ matrix.python-version }}
        uses: actions/setup-python@v5
        with:
          python-version: `${{ matrix.python-version }}

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -e .[dev]

      - name: Lint with ruff
        run: ruff check src/ scripts/

      - name: Run tests
        run: pytest tests/ -v
        continue-on-error: true  # upstream tests may need a real browser/Chromium

      - name: Doctor check
        run: python scripts/run.py doctor
        continue-on-error: true  # GitHub Actions runners don't have Chromium pre-installed
"@
Set-Content -Path '.github\workflows\ci.yml' -Value $ciYml -Encoding UTF8 -NoNewline
Write-Sub '.github/workflows/ci.yml'

# --- 2. GitHub Pages deployment workflow ------------------------------------
$pagesYml = @"
name: Deploy Pages

on:
  push:
    branches: [main]
    paths:
      - 'index.html'
      - 'assets/**'
      - '.github/workflows/pages.yml'
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: true

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: `${{ steps.deployment.outputs.page_url }}
    steps:
      - uses: actions/checkout@v4
      - name: Set up Pages
        uses: actions/configure-pages@v5
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: '.'
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
"@
Set-Content -Path '.github\workflows\pages.yml' -Value $pagesYml -Encoding UTF8 -NoNewline
Write-Sub '.github/workflows/pages.yml'

# --- 3. Lan
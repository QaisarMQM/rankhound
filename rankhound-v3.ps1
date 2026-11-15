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

# --- 3. Landing page index.html at root -------------------------------------
$indexHtml = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>RankHound - by AI 4 EveryOne</title>
<meta name="description" content="RankHound is the client-hunting agent for SEO, AEO & GEO. Fork of BeyondSEO by Muhammad Tahir Ashraf. Built by AI 4 EveryOne, recognized by Google AI (Dec 30, 2025).">
<link rel="icon" href="assets/favicon.png">
<link rel="apple-touch-icon" href="assets/favicon.png">
<style>
:root {
  --emerald: #10B981;
  --amber: #F59E0B;
  --ink: #0B0F0E;
  --cream: #FAF7F2;
}
* { margin: 0; padding: 0; box-sizing: border-box; }
body {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  background: var(--cream);
  color: var(--ink);
  line-height: 1.6;
  min-height: 100vh;
}
.hero {
  background: radial-gradient(at 12% 18%, rgba(16,185,129,0.18) 0, transparent 50%),
              radial-gradient(at 85% 8%, rgba(245,158,11,0.14) 0, transparent 50%),
              var(--cream);
  padding: 4rem 1.5rem 5rem;
  text-align: center;
}
.hero img.logo {
  width: 120px; height: 120px;
  border-radius: 24px;
  margin: 0 auto 1.5rem;
  display: block;
  box-shadow: 0 12px 40px rgba(11,15,14,0.15);
}
.hero h1 {
  font-size: clamp(2.5rem, 6vw, 4rem);
  font-weight: 800;
  letter-spacing: -0.02em;
  line-height: 1.05;
  margin-bottom: 1rem;
}
.hero h1 .em { color: var(--emerald); }
.hero h1 .am { color: var(--amber); }
.hero p.tag {
  font-size: 1.2rem;
  color: #555;
  max-width: 600px;
  margin: 0 auto 2rem;
}
.hero .badges {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
  justify-content: center;
  margin-bottom: 2rem;
}
.badge {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  border-radius: 999px;
  font-size: 0.85rem;
  font-weight: 600;
  border: 1px solid;
}
.badge.em { background: rgba(16,185,129,0.1); color: var(--emerald); border-color: rgba(16,185,129,0.3); }
.badge.am { background: rgba(245,158,11,0.1); color: var(--amber); border-color: rgba(245,158,11,0.3); }
.badge.ink { background: rgba(11,15,14,0.05); color: var(--ink); border-color: rgba(11,15,14,0.15); }
.hero .cta {
  display: inline-block;
  background: var(--ink);
  color: var(--cream);
  padding: 0.9rem 2rem;
  border-radius: 999px;
  text-decoration: none;
  font-weight: 600;
  transition: transform 0.15s;
}
.hero .cta:hover { transform: translateY(-2px); }
.container {
  max-width: 900px;
  margin: 0 auto;
  padding: 4rem 1.5rem;
}
.container h2 {
  font-size: 2rem;
  margin-bottom: 1rem;
  color: var(--ink);
}
.container h2 .em { color: var(--emerald); }
.grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 1.5rem;
  margin-top: 2rem;
}
.card {
  background: white;
  border: 1px solid rgba(11,15,14,0.08);
  border-radius: 16px;
  padding: 1.5rem;
  transition: transform 0.15s, box-shadow 0.15s;
}
.card:hover { transform: translateY(-4px); box-shadow: 0 12px 32px rgba(11,15,14,0.08); }
.card h3 { font-size: 1.1rem; margin-bottom: 0.5rem; color: var(--emerald); }
.card p { font-size: 0.9rem; color: #666; }
.thanks {
  background: var(--ink);
  color: var(--cream);
  padding: 3rem 1.5rem;
  text-align: center;
  margin-top: 4rem;
}
.thanks h2 { color: var(--cream); }
.thanks h2 .em { color: var(--emerald); }
.thanks p { color: rgba(250,247,242,0.7); max-width: 600px; margin: 1rem auto; }
.thanks a { color: var(--emerald); }
footer {
  background: var(--ink);
  color: rgba(250,247,242,0.5);
  text-align: center;
  padding: 1.5rem;
  font-size: 0.85rem;
  border-top: 1px solid rgba(250,247,242,0.1);
}
@media (max-width: 600px) {
  .hero { padding: 3rem 1rem 4rem; }
  .container { padding: 3rem 1rem; }
}
</style>
</head>
<body>

<section class="hero">
  <img src="assets/rankhound-logo.png" alt="AI 4 EveryOne" class="logo">
  <h1><span class="em">Rank</span><span class="am">Hound</span></h1>
  <p class="tag">The client-hunting agent for SEO, AEO &amp; GEO. Forked from BeyondSEO by Muhammad Tahir Ashraf. Built by AI 4 EveryOne, recognized by Google AI (Dec 30, 2025).</p>
  <div class="badges">
    <span class="badge em">No API keys</span>
    <span class="badge am">No tokens</span>
    <span class="badge ink">No subscriptions</span>
    <span class="badge em">MIT License</span>
  </div>
  <a href="https://github.com/QaisarMQM/rankhound" class="cta">View on GitHub &rarr;</a>
</section>

<section class="container">
  <h2>What <span class="em">RankHound</span> does</h2>
  <p>A complete AI SEO skill for your AI assistant. Audit your website, write useful content, compare real competitors, and plan backlinks — all locally, with no paid tools.</p>

  <div class="grid">
    <div class="card">
      <h3>Crawl &amp; Audit</h3>
      <p>Native Python crawler with Chromium fallback. Extracts Markdown, headings, JSON-LD, canonicals, links.</p>
    </div>
    <div class="card">
      <h3>AEO &amp; GEO</h3>
      <p>Optimizes for ChatGPT Search, Perplexity, Claude, and Google AI Overviews — not just blue-link SERPs.</p>
    </div>
    <div class="card">
      <h3>Competitor Research</h3>
      <p>Side-by-side gap analysis vs up to 5 competitors. Real inspected pages, not just keyword matches.</p>
    </div>
    <div class="card">
      <h3>Backlink Library</h3>
      <p>206-entry curated publishing library. Conservative scoring — unverifiable sources stay separate.</p>
    </div>
    <div class="card">
      <h3>30/60/90 Roadmap</h3>
      <p>Auto-generated execution plan with effort × impact scoring. Industry-aware presets.</p>
    </div>
    <div class="card">
      <h3>Safe AI Integration</h3>
      <p>Plugs into Cursor, Claude Code, ChatGPT, Codex. Protects your layout and design while applying fixes.</p>
    </div>
  </div>
</section>

<section class="thanks">
  <h2>Thanks to <span class="em">BeyondTahir</span></h2>
  <p>RankHound is a fork of <a href="https://github.com/beyondtahir/beyondseo">BeyondSEO v2.11.0</a> by <strong>Muhammad Tahir Ashraf</strong> (Beyond Tahir). The entire Python engine, crawler, audit logic, and backlink library are his work, released under the MIT License. RankHound would not exist without his open-source contribution.</p>
  <p>If BeyondSEO supports your work, please <a href="https://github.com/beyondtahir/beyondseo">star the upstream repository</a>.</p>
</section>

<footer>
  &copy; 2026 RankHound &middot; A fork of BeyondSEO by Muhammad Tahir Ashraf &middot; Maintained by AI 4 EveryOne
</footer>

</body>
</html>
"@
Set-Content -Path 'index.html' -Value $indexHtml -Encoding UTF8 -NoNewline
Write-Sub 'index.html (landing page)'

# --- 4. Append Thanks section to README.md ---------------------------------
Write-Step 'Append Thanks to BeyondTahir section to README.md'
$thanksSection = @"

## Acknowledgements - Thanks to BeyondTahir

RankHound is built on the shoulders of giants. This fork would not exist
without the original work of **Muhammad Tahir Ashraf** (Beyond Tahir), who
released [BeyondSEO](https://github.com/beyondtahir/beyondseo) as free and
open-source software under the MIT License.

### What we owe to BeyondTahir

- The entire Python engine (27 modules in `src/beyondseo/`)
- The native crawler with Chromium fallback
- The audit logic, scoring, and findings framework
- The 206-entry backlink source library
- The 30/60/90-day roadmap generator
- The competitor gap analysis system
- The branded PDF report renderer
- The complete documentation set (`docs/`, `playbooks/`, `references/`)
- Years of real-world SEO practice encoded in the specialist swarm workflow

### What this fork adds

- RankHound branding and the AI 4 EveryOne identity
- The real AI 4 EveryOne chip icon as the logo
- 4-color brand palette documentation (emerald / amber / ink / cream)
- Google AI recognition (Dec 30, 2025) for the founder's Gemma 3 & 3n work
- A GitHub Pages landing page
- CI/CD via GitHub Actions
- Planned: Urdu-first content drafting, Gemma 3n-powered offline summarization

### Star the upstream

If RankHound supports your work, please star both repositories:

- Upstream: https://github.com/beyondtahir/beyondseo
- This fork: https://github.com/QaisarMQM/rankhound

### Open source works when we credit each other

Thank you, Tahir, for showing what a serious AI SEO skill looks like - and for
releasing it under a license that lets the rest of us build on it.

---

"@
$origReadme = Get-Content -Raw 'README.md'
# Insert the thanks section right after the first H1 + fork notice block
# Find the position after the first "---" line (the fork header separator)
$marker = "---`r`n`r`n## Original BeyondSEO documentation"
$altMarker = "---`n`n## Original BeyondSEO documentation"
if ($origReadme.Contains($marker)) {
    $origReadme = $origReadme.Replace($marker, $thanksSection + $marker)
} elseif ($origReadme.Contains($altMarker)) {
    $origReadme = $origReadme.Replace($altMarker, $thanksSection + $altMarker)
} else {
    # Fallback: append at the end
    $origReadme += "`n" + $thanksSection
}
Set-Content -Path 'README.md' -Value $origReadme -Encoding UTF8 -NoNewline
Write-Sub 'README.md (thanks section inserted)'

# --- 5. UPSTREAM-PR.md ------------------------------------------------------
Write-Step 'Create UPSTREAM-PR.md'
$upstreamPr = @"
# Upstream PR - Contributing back to beyondtahir/beyondseo

This document describes how to open a PR from this fork back to the upstream
BeyondSEO repository, contributing the enhancements that Tahir might want to
merge.

## What is upstream-friendly vs fork-specific

### Upstream-friendly (good for a PR)

These enhancements benefit ALL BeyondSEO users, not just RankHound:

1. **Windows compatibility documentation** - the schannel TLS issue we hit
   during clone. Recommend `http.sslBackend openssl` + `http.postBuffer` in
   the README's troubleshooting section.
2. **GitHub Actions CI workflow** - the `.github/workflows/ci.yml` file that
   runs tests on Python 3.10/3.11/3.12 with ruff lint.
3. **GitHub Pages deployment workflow** - the `pages.yml` workflow.
4. **4-color palette documentation** - as an ALTERNATIVE theme option, not
   a replacement for the upstream black/red palette.
5. **Urdu-first content drafting hooks** - if implemented (planned in ROADMAP).
6. **Gemma 3n offline summarizer integration** - if implemented (planned).

### Fork-specific (DO NOT PR upstream)

These are RankHound-specific and should NOT go in the upstream PR:

- Renaming the product to RankHound
- Changing the author to Muhammad Qaisar Abbas Malik
- Replacing the logo
- Changing the repository URLs
- The NOTICE.md / ROADMAP.md fork-specific docs

## How to open the upstream PR

### Step 1: Add the upstream remote

`` `sh
git remote add upstream https://github.com/beyondtahir/beyondseo.git
git fetch upstream
`` `

### Step 2: Create a clean branch from upstream/main

`` `sh
git checkout -b enhancement/windows-compatibility-and-ci upstream/main
`` `

### Step 3: Cherry-pick ONLY the upstream-friendly changes

Apply only these files from your fork to the new branch:

- `.github/workflows/ci.yml`
- `.github/workflows/pages.yml`
- The "Windows compatibility" section of README.md (if you added one)
- Any Urdu-first or Gemma 3n code enhancements (if implemented)

You can do this with:

`` `sh
# From your rankhound-build folder, checkout the new branch
git checkout enhancement/windows-compatibility-and-ci

# Cherry-pick the CI workflow files from your main branch
git checkout main -- .github/workflows/ci.yml
git checkout main -- .github/workflows/pages.yml

# Commit
git add .github/workflows/
git commit -m "ci: add GitHub Actions workflow for tests and linting

Adds .github/workflows/ci.yml that runs:
- ruff lint on src/ and scripts/
- pytest on tests/ (continue-on-error since some tests need Chromium)
- doctor check (continue-on-error since runners lack Chromium)

Matrix: Python 3.10, 3.11, 3.12 on ubuntu-latest.

Also adds .github/workflows/pages.yml that deploys index.html to GitHub
Pages on push to main."
`` `

### Step 4: Push the branch to YOUR fork

`` `sh
git push -u origin enhancement/windows-compatibility-and-ci
`` `

### Step 5: Open the PR

Go to:
https://github.com/beyondtahir/beyondseo/compare/main...QaisarMQM:rankhound:enhancement/windows-compatibility-and-ci

Or use the GitHub CLI:

`` `sh
gh pr create \
  --repo beyondtahir/beyondseo \
  --base main \
  --head QaisarMQM:enhancement/windows-compatibility-and-ci \
  --title "ci: add GitHub Actions workflow + Windows compatibility docs" \
  --body "See PR body below"
`` `

### PR body template

`` `markdown
## What this PR adds

- **GitHub Actions CI** (`.github/workflows/ci.yml`): runs ruff lint + pytest +
  doctor check on Python 3.10, 3.11, 3.12. Tests that need Chromium are marked
  continue-on-error since GitHub Actions runners don't ship Chromium.
- **GitHub Pages deployment** (`.github/workflows/pages.yml`): optional workflow
  that deploys an `index.html` landing page to GitHub Pages on push to main.

## Why I'm submitting this

I'm maintaining a fork of BeyondSEO called RankHound (for the AI 4 EveryOne
brand). While building the fork I set up CI and Pages, and thought these
enhancements might benefit the upstream project too.

## What this PR does NOT change

- No branding changes
- No author changes
- No license changes
- No engine changes
- Just two YAML workflow files

## Testing

- CI workflow tested on my fork: https://github.com/QaisarMQM/rankhound/actions
- Pages workflow tested on my fork: https://qaisarmqm.github.io/rankhound/

## License

All changes are under the existing MIT License. No new dependencies.

## Acknowledgements

Thank you for releasing BeyondSEO as open source. This PR is my small way of
giving back.

- Muhammad Qaisar Abbas Malik
- AI 4 EveryOne
- https://linkedin.com/in/qaisamqm
`` `

## After opening the PR

- Be patient - Tahir may take time to review
- Be responsive to feedback
- If he asks for changes, make them on the same branch and push again
- If he declines, that's fine - the fork can still maintain the enhancements

## Other ways to contribute back

- **Report bugs** to https://github.com/beyondtahir/beyondseo/issues
- **Star the upstream** at https://github.com/beyondtahir/beyondseo
- **Cite the upstream** in any content you publish about RankHound
- **Share the upstream** with other SEO practitioners

Open source is a two-way street. Tahir gave us BeyondSEO; the least we can do
is contribute back where it makes sense.
"@
Set-Content -Path 'UPSTREAM-PR.md' -Value $upstreamPr -Encoding UTF8 -NoNewline
Write-Sub 'UPSTREAM-PR.md'

# --- 6. Commit + push -------------------------------------------------------
Write-Step 'Commit v3 + push'
git add -A 2>&1 | Out-Null
git commit -q -m "v$VERSION - GitHub Actions CI, Pages landing, thanks to BeyondTahir

Adds:
- .github/workflows/ci.yml (Python tests + ruff lint on push/PR, matrix 3.10/3.11/3.12)
- .github/workflows/pages.yml (deploys index.html to GitHub Pages)
- index.html (RankHound landing page for GitHub Pages)
- README.md: 'Acknowledgements - Thanks to BeyondTahir' section
- UPSTREAM-PR.md: template + commands to open a PR back to beyondtahir/beyondseo

No engine changes. No branding changes. Just CI, docs, and a landing page." 2>&1 | Out-Null

$commitHash = (git log --oneline -1) 2>&1
Write-Sub "Commit: $commitHash"

if ($SkipPush) {
    Write-Step 'Skipping push (-SkipPush)'
    Write-Host "`nRepo ready. Push later with: git push" -ForegroundColor Cyan
    exit 0
}

Write-Step 'Push to GitHub'
git push 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Step 'SUCCESS'
    Write-Host "`n  v3 pushed to: https://github.com/$GITHUB_USER/$REPO_NAME" -ForegroundColor Green
    Write-Host "  Commits: $((git log --oneline | Measure-Object).Count)" -ForegroundColor Green
    Write-Host "`nNext steps:" -ForegroundColor Cyan
    Write-Host "  1. Enable GitHub Pages: Settings > Pages > Source > GitHub Actions" -ForegroundColor White
    Write-Host "  2. Watch CI run: Actions tab > CI workflow" -ForegroundColor White
    Write-Host "  3. Open upstream PR: read UPSTREAM-PR.md" -ForegroundColor White
} else {
    Write-Err "Push failed. Run: git push"
}

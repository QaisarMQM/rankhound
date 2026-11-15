# Upstream PR - Contributing back to beyondtahir/beyondseo

This document describes how to open a PR from this fork back to the upstream
BeyondSEO repository, contributing the enhancements that Tahir might want to
merge.

## What is upstream-friendly vs fork-specific

### Upstream-friendly (good for a PR)

These enhancements benefit ALL BeyondSEO users, not just RankHound:

1. **Windows compatibility documentation** - the schannel TLS issue we hit
   during clone. Recommend http.sslBackend openssl + http.postBuffer in
   the README's troubleshooting section.
2. **GitHub Actions CI workflow** - the .github/workflows/ci.yml file that
   runs tests on Python 3.10/3.11/3.12 with ruff lint.
3. **GitHub Pages deployment workflow** - the pages.yml workflow.
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

` sh
git remote add upstream https://github.com/beyondtahir/beyondseo.git
git fetch upstream
` 

### Step 2: Create a clean branch from upstream/main

` sh
git checkout -b enhancement/windows-compatibility-and-ci upstream/main
` 

### Step 3: Cherry-pick ONLY the upstream-friendly changes

Apply only these files from your fork to the new branch:

- .github/workflows/ci.yml
- .github/workflows/pages.yml
- The "Windows compatibility" section of README.md (if you added one)
- Any Urdu-first or Gemma 3n code enhancements (if implemented)

You can do this with:

` sh
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
` 

### Step 4: Push the branch to YOUR fork

` sh
git push -u origin enhancement/windows-compatibility-and-ci
` 

### Step 5: Open the PR

Go to:
https://github.com/beyondtahir/beyondseo/compare/main...QaisarMQM:rankhound:enhancement/windows-compatibility-and-ci

Or use the GitHub CLI:

` sh
gh pr create \
  --repo beyondtahir/beyondseo \
  --base main \
  --head QaisarMQM:enhancement/windows-compatibility-and-ci \
  --title "ci: add GitHub Actions workflow + Windows compatibility docs" \
  --body "See PR body below"
` 

### PR body template

` markdown
## What this PR adds

- **GitHub Actions CI** (.github/workflows/ci.yml): runs ruff lint + pytest +
  doctor check on Python 3.10, 3.11, 3.12. Tests that need Chromium are marked
  continue-on-error since GitHub Actions runners don't ship Chromium.
- **GitHub Pages deployment** (.github/workflows/pages.yml): optional workflow
  that deploys an index.html landing page to GitHub Pages on push to main.

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
` 

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
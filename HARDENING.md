<!-- markdownlint-disable -->

# Hardening Report: fabasoad--setup-mint-action/v1.4.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **fabasoad--setup-mint-action/v1.4.1** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Direct ${{ ... }} expression interpolation inside run: shell commands. In the 'Prepare binary name template' step, `${{ format('{0}-{1}', case(runner.os == 'macOS', 'osx', 'linux'), case(startsWith(runner.arch, 'ARM'), 'arm64', 'x86_64')) }}` is interpolated directly into the shell script. In the 'Install mint' step, `${{ format(steps.binary-name.outputs.template, steps.download-binary.outputs.tag_name) }}` (which includes workflow-controllable steps.*.outputs.*) is interpolated directly into the mv command inside a run: block.

Locations:

- `action.yml:47`
- `action.yml:65`

### script-injection (severity: high)

Sub-rule (a): Direct ${{ ... }} expression interpolation inside run: shell commands in workflow files. In the 'Prepare list' step, `${{ steps.github-releases.outputs.releases }}` (steps.*.outputs.* is workflow-controllable) is interpolated directly into an echo command. In the 'Test action completion' step, `${{ steps.setup-mint-1.outputs.installed }}`, `${{ steps.setup-mint-2.outputs.installed }}`, and `${{ matrix.force }}` are all interpolated directly into shell command strings.

Locations:

- `.github/workflows/functional-tests.yml:40`
- `.github/workflows/functional-tests.yml:88`
- `.github/workflows/functional-tests.yml:90`
- `.github/workflows/functional-tests.yml:91`

### github-env-injection (severity: high)

In the 'Prepare binary name template' step of action.yml, the shell variable `template` is constructed by directly embedding `${{ format('{0}-{1}', case(runner.os == 'macOS', 'osx', 'linux'), case(startsWith(runner.arch, 'ARM'), 'arm64', 'x86_64')) }}` (a workflow-expression value) and then written to $GITHUB_OUTPUT via `echo "template=${template}" >> "$GITHUB_OUTPUT"` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`).

Locations:

- `action.yml:51`

### unpinned-uses (severity: high)

Multiple uses: references are pinned to mutable tags or branch names instead of immutable 40-character commit SHAs, making the action vulnerable to supply-chain attacks. Failing references: action.yml: `robinraju/release-downloader@v1`; functional-tests.yml: `yakubique/github-releases@v1.2`, `actions/checkout@v7` (two occurrences); linting.yml: `fabasoad/reusable-workflows/...@main`; release.yml: `fabasoad/reusable-workflows/...@main`; security.yml: `fabasoad/reusable-workflows/...@main`; sync-labels.yml: `fabasoad/reusable-workflows/...@main`; update-license.yml: `fabasoad/reusable-workflows/...@main`.

Locations:

- `action.yml:55`
- `.github/workflows/functional-tests.yml:33`
- `.github/workflows/functional-tests.yml:55`
- `.github/workflows/functional-tests.yml:76`
- `.github/workflows/linting.yml:8`
- `.github/workflows/release.yml:8`
- `.github/workflows/security.yml:22`
- `.github/workflows/sync-labels.yml:8`
- `.github/workflows/update-license.yml:8`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, unpinned-uses

**Notes:**

Fixed all findings: (1) script-injection in action.yml 'Prepare binary name template' step - moved ${{ format(...) }} to BINARY_SUFFIX env var; (2) script-injection in action.yml 'Install mint' step - moved ${{ format(steps.binary-name.outputs.template, steps.download-binary.outputs.tag_name) }} to BINARY_FILENAME env var; (3) github-env-injection in action.yml - added printf/tr sanitization before writing template to $GITHUB_OUTPUT; (4) script-injection in functional-tests.yml 'Prepare list' step - moved steps.github-releases.outputs.releases to RELEASES_JSON env var; (5) script-injection in functional-tests.yml 'Test action completion' step - moved steps.setup-mint-1.outputs.installed, steps.setup-mint-2.outputs.installed, and matrix.force to env vars; (6) pinned robinraju/release-downloader@v1 to SHA 28fc21f50d76778e7023361aa1f863e717d3d56f; (7) pinned yakubique/github-releases@v1.2 to SHA 2827d6f627dc289b8cbbc9b4d030956d67c37c68; (8) pinned both actions/checkout@v7 to SHA 9c091bb21b7c1c1d1991bb908d89e4e9dddfe3e0; (9) pinned all 5 fabasoad/reusable-workflows@main references to SHA 3ae541f80e3e6aca1f2c3705477fbef2890f1c98.


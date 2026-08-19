<!-- markdownlint-disable -->

# Hardening Report: fabasoad--setup-mint-action/v1.4.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **fabasoad--setup-mint-action/v1.4.0** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Multiple `uses:` references are pinned to mutable tags or branch names instead of immutable 40-character commit SHAs, making the action vulnerable to supply-chain attacks if the referenced tag or branch is moved or compromised. Failing references:
- action.yml: `robinraju/release-downloader@v1`
- functional-tests.yml: `yakubique/github-releases@v1.2`, `actions/checkout@v4` (×2)
- linting.yml: `fabasoad/reusable-workflows/.github/workflows/wf-pre-commit.yml@main`
- release.yml: `fabasoad/reusable-workflows/.github/workflows/wf-github-release.yml@main`
- security.yml: `fabasoad/reusable-workflows/.github/workflows/wf-security-sast.yml@main`
- sync-labels.yml: `fabasoad/reusable-workflows/.github/workflows/wf-sync-labels.yml@main`
- update-license.yml: `fabasoad/reusable-workflows/.github/workflows/wf-update-license.yml@main`

Locations:

- `action.yml:48`
- `.github/workflows/functional-tests.yml:31`
- `.github/workflows/functional-tests.yml:54`
- `.github/workflows/functional-tests.yml:70`
- `.github/workflows/linting.yml:6`
- `.github/workflows/release.yml:6`
- `.github/workflows/security.yml:9`
- `.github/workflows/sync-labels.yml:7`
- `.github/workflows/update-license.yml:7`

### script-injection (severity: high)

Sub-rule (a): GitHub Actions expressions (`${{ ... }}`) are interpolated directly inside `run:` shell command strings, allowing an attacker to inject arbitrary shell commands.

1. action.yml, 'Install mint' step (line 58): `tag_name="${{ steps.download-binary.outputs.tag_name }}"` and `mv "mint-${tag_name}-${{ runner.os == 'Linux' && 'linux' || 'osx' }}-${{ startsWith(runner.arch, 'ARM') && 'arm64' || 'x86_64' }}" mint` — `steps.*.outputs.*` and `runner.*` expressions are interpolated directly into the shell script before the shell parses it.

2. functional-tests.yml, 'Prepare list' step (line 41): `versions=$(echo '${{ steps.github-releases.outputs.releases }}' | jq ...)` — a step output is interpolated directly into the run block.

3. functional-tests.yml, 'Test action completion' step (lines 88–92): `"${{ steps.setup-mint-1.outputs.installed }}"`, `"${{ steps.setup-mint-2.outputs.installed }}"`, and `"${{ matrix.force }}"` are interpolated directly into the shell script.

Locations:

- `action.yml:58`
- `action.yml:59`
- `.github/workflows/functional-tests.yml:41`
- `.github/workflows/functional-tests.yml:88`
- `.github/workflows/functional-tests.yml:90`
- `.github/workflows/functional-tests.yml:92`

### missing-permissions (severity: medium)

The following workflow files have no top-level `permissions:` key and no job-level `permissions:` key on any of their jobs. Without explicit permissions, workflows inherit the default repository token permissions (which may be `write-all` depending on repository settings), granting unnecessary access.
- functional-tests.yml: jobs `get-versions`, `setup-mint`, and `test-force` all lack permissions.
- linting.yml: job `pre-commit` lacks permissions.
- release.yml: job `github` lacks permissions.
- sync-labels.yml: job `maintenance` lacks permissions.
- update-license.yml: job `maintenance` lacks permissions.

Locations:

- `.github/workflows/functional-tests.yml:1`
- `.github/workflows/linting.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/sync-labels.yml:1`
- `.github/workflows/update-license.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection, missing-permissions

**Notes:**

Fixed all three findings:

1. unpinned-uses: Pinned all mutable references to full 40-char SHAs:
   - robinraju/release-downloader@v1 → @28fc21f50d76778e7023361aa1f863e717d3d56f
   - yakubique/github-releases@v1.2 → @2827d6f627dc289b8cbbc9b4d030956d67c37c68
   - actions/checkout@v4 → @34e114876b0b11c390a56381ad16ebd13914f8d5
   - fabasoad/reusable-workflows@main → @4e2279474e598bee3ae8ded28899a24bbc7bf971 (all 5 workflow files)

2. script-injection: Moved all ${{ }} expressions from run: blocks to env: blocks:
   - action.yml 'Install mint': TAG_NAME, RUNNER_OS_LOWER, RUNNER_ARCH_LOWER env vars
   - functional-tests.yml 'Prepare list': RELEASES_JSON env var
   - functional-tests.yml 'Test action completion': INSTALLED_1, INSTALLED_2, MATRIX_FORCE env vars

3. missing-permissions: Added job-level permissions to all jobs lacking them:
   - functional-tests.yml jobs: contents: read
   - linting.yml pre-commit: contents: read
   - release.yml github: contents: write
   - sync-labels.yml maintenance: contents: read, issues: write
   - update-license.yml maintenance: contents: write

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in .github/workflows/functional-tests.yml at the 'Prepare list' step. Added a sanitization step: `safe_versions=$(printf '%s' "${versions}" | tr -d '\n\r')` and changed the GITHUB_OUTPUT write to use `safe_versions` instead of `versions`. This prevents a malicious release name containing newlines from injecting arbitrary key=value pairs into GITHUB_OUTPUT.


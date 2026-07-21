<!-- markdownlint-disable -->

# Hardening Report: fabasoad--setup-mint-action/v1.4.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **fabasoad--setup-mint-action/v1.4.1** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): ${{ }} expressions are interpolated directly inside run: shell command strings in action.yml. In the 'Prepare binary name template' step, `${{ format('{0}-{1}', case(runner.os == 'macOS', 'osx', 'linux'), case(startsWith(runner.arch, 'ARM'), 'arm64', 'x86_64')) }}` is embedded directly in a shell variable assignment. In the 'Install mint' step, `${{ format(steps.binary-name.outputs.template, steps.download-binary.outputs.tag_name) }}` is embedded directly in an mv command. Any ${{ }} expression inside a run: block is a script-injection risk because YAML template substitution occurs before the shell ever sees the string.

Locations:

- `action.yml:51`
- `action.yml:74`

### script-injection (severity: high)

Rule (a): ${{ }} expressions are interpolated directly inside run: shell command strings in functional-tests.yml. In the 'Prepare list' step, `${{ steps.github-releases.outputs.releases }}` is embedded directly in a shell command (line 45). In the 'Test action completion' step, `${{ steps.setup-mint-1.outputs.installed }}`, `${{ steps.setup-mint-2.outputs.installed }}`, and `${{ matrix.force }}` are all embedded directly as shell arguments (lines 103, 106, 107). These values flow through YAML template substitution before the shell parses them, enabling command injection.

Locations:

- `.github/workflows/functional-tests.yml:45`
- `.github/workflows/functional-tests.yml:103`
- `.github/workflows/functional-tests.yml:106`
- `.github/workflows/functional-tests.yml:107`

### unpinned-uses (severity: high)

Multiple uses: references are pinned to mutable tags or branch names instead of immutable 40-character commit SHAs, making the action vulnerable to supply-chain attacks if the referenced tag or branch is moved or compromised. Failing references: action.yml: `robinraju/release-downloader@v1`; functional-tests.yml: `yakubique/github-releases@v1.2`, `actions/checkout@v7` (×2); linting.yml: `fabasoad/reusable-workflows/.github/workflows/wf-pre-commit.yml@main`; release.yml: `fabasoad/reusable-workflows/.github/workflows/wf-github-release.yml@main`; security.yml: `fabasoad/reusable-workflows/.github/workflows/wf-security-sast.yml@main`; sync-labels.yml: `fabasoad/reusable-workflows/.github/workflows/wf-sync-labels.yml@main`; update-license.yml: `fabasoad/reusable-workflows/.github/workflows/wf-update-license.yml@main`.

Locations:

- `action.yml:61`
- `.github/workflows/functional-tests.yml:34`
- `.github/workflows/functional-tests.yml:62`
- `.github/workflows/functional-tests.yml:83`
- `.github/workflows/linting.yml:12`
- `.github/workflows/release.yml:10`
- `.github/workflows/security.yml:17`
- `.github/workflows/sync-labels.yml:11`
- `.github/workflows/update-license.yml:11`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, unpinned-uses

**Notes:**

Fixed all script-injection findings by moving ${{ }} expressions from run: shell strings into step env: blocks and referencing them as plain environment variables. Fixed all unpinned-uses findings by resolving mutable tags/branches to full 40-character commit SHAs: robinraju/release-downloader@v1→28fc21f50d76778e7023361aa1f863e717d3d56f, yakubique/github-releases@v1.2→2827d6f627dc289b8cbbc9b4d030956d67c37c68, actions/checkout@v7→3d3c42e5aac5ba805825da76410c181273ba90b1, fabasoad/reusable-workflows@main→10062f8186847226cb4865efbb8047795d372bae (applied to linting.yml, release.yml, security.yml, sync-labels.yml, update-license.yml).

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed the github-env-injection finding in .github/workflows/functional-tests.yml at line 43. In the 'Prepare list' step of the 'get-versions' job, the `versions` value (derived from the untrusted GITHUB_RELEASES step output) was being written directly to $GITHUB_OUTPUT. Added sanitization using `safe_versions=$(printf '%s' "${versions}" | tr -d '\n\r')` and changed the echo to use `safe_versions` instead of `versions`, preventing newline injection attacks.


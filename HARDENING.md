<!-- markdownlint-disable -->

# Hardening Report: fabasoad--setup-mint-action/v1.3.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **fabasoad--setup-mint-action/v1.3.1** was hardened automatically. 4 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

The 'Install' step's run: block in action.yml directly interpolates ${{ }} expressions inside shell commands, violating rule (a). Line 42: `mv "${{ steps.info.outputs.mint-binary }}" mint` and line 44: `echo "${{ steps.info.outputs.mint-path }}" >> "$GITHUB_PATH"` both embed GitHub Actions expressions directly in shell code. These values flow through YAML template substitution before the shell sees them, allowing an attacker who controls step outputs to inject shell metacharacters.

Locations:

- `action.yml:42`
- `action.yml:44`

### github-env-injection (severity: high)

The 'Install' step's run: block writes `${{ steps.info.outputs.mint-path }}` directly to $GITHUB_PATH without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). Line 44: `echo "${{ steps.info.outputs.mint-path }}" >> "$GITHUB_PATH"`. A newline embedded in the step output value could inject arbitrary entries into the PATH.

Locations:

- `action.yml:44`

### unpinned-uses (severity: high)

Multiple `uses:` references are pinned to mutable tags or branch names instead of immutable 40-character commit SHAs, making the action vulnerable to supply-chain attacks if those refs are moved or compromised. Failing references: action.yml: `robinraju/release-downloader@v1.11`; functional-tests.yml: `actions/checkout@v4`; linting.yml: `fabasoad/reusable-workflows/.github/workflows/wf-pre-commit.yml@main`; release.yml: `fabasoad/reusable-workflows/.github/workflows/wf-github-release.yml@main`; sync-labels.yml: `fabasoad/reusable-workflows/.github/workflows/wf-sync-labels.yml@main`; update-license.yml: `fabasoad/reusable-workflows/.github/workflows/wf-update-license.yml@main`.

Locations:

- `action.yml:31`
- `.github/workflows/functional-tests.yml:34`
- `.github/workflows/linting.yml:11`
- `.github/workflows/release.yml:9`
- `.github/workflows/sync-labels.yml:10`
- `.github/workflows/update-license.yml:9`

### missing-permissions (severity: medium)

Five workflow files have no top-level `permissions:` key and no job-level `permissions:` key on any of their jobs. Without explicit permissions, workflows run with the default (potentially broad) token permissions. Affected files: functional-tests.yml, linting.yml, release.yml, sync-labels.yml, update-license.yml.

Locations:

- `.github/workflows/functional-tests.yml:1`
- `.github/workflows/linting.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/sync-labels.yml:1`
- `.github/workflows/update-license.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, unpinned-uses, missing-permissions

**Notes:**

Fixed all four finding types: (1) script-injection in action.yml Install step - moved ${{ steps.info.outputs.mint-binary }} and ${{ steps.info.outputs.mint-path }} into env: block as MINT_BINARY and MINT_PATH; (2) github-env-injection - added printf '%s' | tr -d '\n\r' sanitization before writing to $GITHUB_PATH; (3) unpinned-uses - pinned robinraju/release-downloader@v1.11 to SHA a96f54c1b5f5e09e47d9504526e96febd949d4c2, actions/checkout@v4 to SHA 11d5960a326750d5838078e36cf38b85af677262, and all four fabasoad/reusable-workflows@main references to SHA c5bd8945762dab6d2f5168b65f10355887ea40a3; (4) missing-permissions - added 'permissions: {}' top-level block to functional-tests.yml, linting.yml, release.yml, sync-labels.yml, and update-license.yml.

### Iteration 2

**Fixes applied:** github-env-injection, unpinned-uses

**Notes:**

1. Fixed github-env-injection in src/collect-info.sh line 47: Added sanitization step using `safe_mint_binary=$(printf '%s' "${mint_binary}" | tr -d '\n\r')` before writing to $GITHUB_OUTPUT, preventing newline injection via user-controlled `inputs.version`. 2. Fixed unpinned-uses in .github/workflows/security.yml line 15: Replaced mutable `@main` branch reference with full commit SHA `@c5bd8945762dab6d2f5168b65f10355887ea40a3` (with `# main` comment for readability).


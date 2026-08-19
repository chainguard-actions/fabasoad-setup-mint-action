<!-- markdownlint-disable -->

# Hardening Report: fabasoad--setup-mint-action/v1.3.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **fabasoad--setup-mint-action/v1.3.2** was hardened automatically. 4 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

The 'Install' step in action.yml directly interpolates ${{ steps.info.outputs.mint-binary }} and ${{ steps.info.outputs.mint-path }} inside a run: shell block (sub-rule a). These ${{ ... }} expressions are expanded by the Actions template engine before the shell ever sees them, allowing a workflow-controlled value to inject arbitrary shell commands. Offending lines:
  mv "${{ steps.info.outputs.mint-binary }}" mint
  echo "${{ steps.info.outputs.mint-path }}" >> "$GITHUB_PATH"
Fix: move these values into env: variables and reference them as quoted shell variables (e.g. "$MINT_BINARY", "$MINT_PATH").

Locations:

- `action.yml:43`

### github-env-injection (severity: high)

The 'Install' step in action.yml writes the value of ${{ steps.info.outputs.mint-path }} directly to $GITHUB_PATH without the required sanitization step (printf '%s' ... | tr -d '\n\r'). A newline embedded in the steps output could inject additional entries into $GITHUB_PATH, enabling path-hijacking attacks. Offending line:
  echo "${{ steps.info.outputs.mint-path }}" >> "$GITHUB_PATH"
Fix: sanitize the value before writing, e.g.:
  safe=$(printf '%s' "$MINT_PATH" | tr -d '\n\r')
  echo "$safe" >> "$GITHUB_PATH"

Locations:

- `action.yml:45`

### unpinned-uses (severity: high)

Multiple uses: references are pinned to mutable tags or branch names rather than immutable 40-character commit SHAs, making the action vulnerable to supply-chain attacks if the referenced tag or branch is moved or compromised.

action.yml:
  - uses: robinraju/release-downloader@v1  (tag)

.github/workflows/functional-tests.yml:
  - uses: actions/checkout@v4  (tag)

.github/workflows/linting.yml:
  - uses: fabasoad/reusable-workflows/.github/workflows/wf-pre-commit.yml@main  (branch)

.github/workflows/release.yml:
  - uses: fabasoad/reusable-workflows/.github/workflows/wf-github-release.yml@main  (branch)

.github/workflows/security.yml:
  - uses: fabasoad/reusable-workflows/.github/workflows/wf-security-sast.yml@main  (branch)

.github/workflows/sync-labels.yml:
  - uses: fabasoad/reusable-workflows/.github/workflows/wf-sync-labels.yml@main  (branch)

.github/workflows/update-license.yml:
  - uses: fabasoad/reusable-workflows/.github/workflows/wf-update-license.yml@main  (branch)

Locations:

- `action.yml:30`
- `.github/workflows/functional-tests.yml:34`
- `.github/workflows/linting.yml:10`
- `.github/workflows/release.yml:9`
- `.github/workflows/security.yml:10`
- `.github/workflows/sync-labels.yml:10`
- `.github/workflows/update-license.yml:9`

### missing-permissions (severity: medium)

The following workflow files have no top-level permissions: key and no job-level permissions: key on any of their jobs. Without explicit permissions, the GITHUB_TOKEN is granted its default (potentially write) permissions, violating the principle of least privilege.

- .github/workflows/functional-tests.yml: no permissions at top level or on job 'functional-tests'
- .github/workflows/linting.yml: no permissions at top level or on job 'pre-commit'
- .github/workflows/release.yml: no permissions at top level or on job 'github'
- .github/workflows/sync-labels.yml: no permissions at top level or on job 'maintenance'
- .github/workflows/update-license.yml: no permissions at top level or on job 'maintenance'

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

Fixed all 4 findings:
1. script-injection (action.yml): Moved ${{ steps.info.outputs.mint-binary }} and ${{ steps.info.outputs.mint-path }} into env: variables (MINT_BINARY, MINT_PATH) in the Install step; shell script now references them as quoted $MINT_BINARY and $MINT_PATH.
2. github-env-injection (action.yml): Added sanitization step `safe=$(printf '%s' "$MINT_PATH" | tr -d '\n\r')` before writing to $GITHUB_PATH.
3. unpinned-uses: Pinned robinraju/release-downloader@v1 → SHA 28fc21f..., actions/checkout@v4 → SHA 11d5960..., and all 5 fabasoad/reusable-workflows@main references → SHA 10062f8... with tag comments preserved.
4. missing-permissions: Added `permissions: {}` top-level block to functional-tests.yml, linting.yml, release.yml, sync-labels.yml, and update-license.yml. security.yml was already compliant with job-level permissions.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

In src/collect-info.sh at line 46, the `mint_binary` value (derived from attacker-controlled `input_version`) was written directly to $GITHUB_OUTPUT without sanitization. Fixed by adding `safe_mint_binary=$(printf '%s' "${mint_binary}" | tr -d '\n\r')` before the echo, and writing `safe_mint_binary` to $GITHUB_OUTPUT instead. This strips any embedded newlines or carriage returns that could be used to inject additional key=value pairs into $GITHUB_OUTPUT.


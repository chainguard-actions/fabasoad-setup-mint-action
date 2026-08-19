<!-- markdownlint-disable -->

# Hardening Report: fabasoad--setup-mint-action/v1.2.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **fabasoad--setup-mint-action/v1.2.1** was hardened automatically. 7 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

action.yml 'Collect info' step directly interpolates ${{ runner.os }} and ${{ inputs.version }} inside the run: shell script (sub-rule a). These expressions are substituted by the YAML template engine before the shell sees them, allowing injection of shell metacharacters. Offending lines: `if [ "${{ runner.os }}" = "Linux" ]; then`, `MINT_BINARY=mint-${{ inputs.version }}-linux`, `MINT_BINARY=mint-${{ inputs.version }}-osx`. The 'Install' step also directly interpolates ${{ steps.info.outputs.MINT_BINARY }} and ${{ steps.info.outputs.MINT_PATH }} in shell commands: `mv ${{ steps.info.outputs.MINT_BINARY }} mint` and `echo "${{ steps.info.outputs.MINT_PATH }}" >> $GITHUB_PATH`.

Locations:

- `action.yml:28`
- `action.yml:29`
- `action.yml:31`
- `action.yml:47`
- `action.yml:49`

### script-injection (severity: high)

pre-commit.yml 'Update git config' step directly interpolates ${{ github.repository }} inside a run: shell command (sub-rule a): `repo=$(echo "${{ github.repository }}" | cut -d "/" -f 2)`. The 'Run pre-commit on changed files' step interpolates ${{ github.sha }} and ${{ github.base_ref }} directly in shell commands: `pre-commit run --to-ref ${{ github.sha }} --from-ref origin/${{ github.base_ref }} ...`. These are attacker-controllable values on pull_request events.

Locations:

- `.github/workflows/pre-commit.yml:22`
- `.github/workflows/pre-commit.yml:26`
- `.github/workflows/pre-commit.yml:27`

### github-env-injection (severity: high)

action.yml 'Collect info' step writes a value derived from ${{ inputs.version }} to $GITHUB_OUTPUT without sanitization. The expression is interpolated into the shell variable MINT_BINARY (e.g. `MINT_BINARY=mint-${{ inputs.version }}-linux`) and then written via `echo "MINT_BINARY=$MINT_BINARY" >> $GITHUB_OUTPUT`. No `printf '%s' ... | tr -d '\n\r'` sanitization is applied before the write. The 'Install' step writes ${{ steps.info.outputs.MINT_PATH }} directly to $GITHUB_PATH: `echo "${{ steps.info.outputs.MINT_PATH }}" >> $GITHUB_PATH`, also without sanitization.

Locations:

- `action.yml:33`
- `action.yml:49`

### unpinned-uses (severity: high)

Multiple uses: references in action.yml and workflow files use mutable version tags instead of pinned 40-character SHA digests, making them vulnerable to supply-chain attacks if the tag is moved. Failing references: action.yml: `actions/github-script@v6`, `robinraju/release-downloader@v1.7`; functional-tests.yml: `actions/checkout@v3`; pre-commit.yml: `actions/checkout@v3`; release.yml: `actions/checkout@v3`, `simbo/changes-since-last-release-action@v1`, `softprops/action-gh-release@v1`, `fischerscode/tagger@v0`; update-license.yml: `actions/checkout@v3`, `FantasticFiasco/action-update-license-year@v3`.

Locations:

- `action.yml:16`
- `action.yml:36`
- `.github/workflows/functional-tests.yml:20`
- `.github/workflows/pre-commit.yml:18`
- `.github/workflows/release.yml:11`
- `.github/workflows/release.yml:14`
- `.github/workflows/release.yml:17`
- `.github/workflows/release.yml:22`
- `.github/workflows/update-license.yml:9`
- `.github/workflows/update-license.yml:10`

### missing-permissions (severity: medium)

None of the four workflow files define a top-level `permissions:` key, and no job within them defines a job-level `permissions:` key. This means all jobs run with the default (potentially broad) GITHUB_TOKEN permissions. Affected files: functional-tests.yml, pre-commit.yml, release.yml, update-license.yml.

Locations:

- `.github/workflows/functional-tests.yml:1`
- `.github/workflows/pre-commit.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/update-license.yml:1`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.version }}" appears directly in run: block of step "Collect info"; move to env: map

Locations:

- `action.yml:29`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.version }}" appears directly in run: block of step "Collect info"; move to env: map

Locations:

- `action.yml:31`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, unpinned-uses, missing-permissions, static-inline-injection

**Notes:**

Fixed all findings across action.yml and 4 workflow files:

1. script-injection (action.yml): Moved runner.os and inputs.version to env: block (RUNNER_OS, INPUT_VERSION) in 'Collect info' step; moved steps.info.outputs.MINT_BINARY and MINT_PATH to env: block in 'Install' step.

2. script-injection (pre-commit.yml): Moved github.repository to env: block (GITHUB_REPOSITORY); moved github.sha and github.base_ref to env: block (GITHUB_SHA, GITHUB_BASE_REF).

3. github-env-injection (action.yml): Added `printf '%s' ... | tr -d '\n\r'` sanitization before writing MINT_BINARY and MINT_PATH to $GITHUB_OUTPUT, and MINT_PATH to $GITHUB_PATH.

4. unpinned-uses: Pinned all 9 action references to full 40-char SHAs with tag comments. Also pinned the pre-commit container image to its sha256 digest.

5. missing-permissions: Added top-level permissions blocks to all 4 workflow files with minimal required permissions (read for test/pre-commit workflows, write for release/update-license workflows).

6. static-inline-injection: Resolved by the same env: block fix applied for script-injection.


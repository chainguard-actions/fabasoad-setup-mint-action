<!-- markdownlint-disable -->

# Hardening Report: fabasoad--setup-mint-action/v1.2.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **fabasoad--setup-mint-action/v1.2.1** was hardened automatically. 5 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple ${{ ... }} expressions are interpolated directly inside run: shell command strings in action.yml, violating sub-rule (a). In the 'Collect info' step: `${{ runner.os }}` and `${{ inputs.version }}` are embedded directly in shell commands (e.g., `if [ "${{ runner.os }}" = "Linux" ]` and `MINT_BINARY=mint-${{ inputs.version }}-linux`). In the 'Install' step: `${{ steps.info.outputs.MINT_BINARY }}` and `${{ steps.info.outputs.MINT_PATH }}` are embedded directly in shell commands (e.g., `mv ${{ steps.info.outputs.MINT_BINARY }} mint` and `echo "${{ steps.info.outputs.MINT_PATH }}" >> $GITHUB_PATH`). These expressions are substituted by the Actions runner before the shell ever sees them, allowing an attacker-controlled value to inject arbitrary shell commands.

Locations:

- `action.yml:24`
- `action.yml:47`

### github-env-injection (severity: high)

Untrusted input is written to special GitHub environment files without sanitization. In the 'Collect info' step, `${{ inputs.version }}` is interpolated directly into the shell to construct MINT_BINARY (e.g., `mint-${{ inputs.version }}-linux`) which is then written to $GITHUB_OUTPUT without the required `printf '%s' ... | tr -d '\n\r'` sanitization step. In the 'Install' step, `${{ steps.info.outputs.MINT_PATH }}` (a step output) is written directly to $GITHUB_PATH without sanitization. An attacker-controlled `inputs.version` could inject newlines to poison GITHUB_OUTPUT or GITHUB_PATH.

Locations:

- `action.yml:24`
- `action.yml:47`

### unpinned-uses (severity: high)

Two `uses:` references in action.yml use mutable tag refs instead of pinned 40-character commit SHAs, making the action vulnerable to supply-chain attacks if the referenced tag is moved or overwritten. Failing references: `actions/github-script@v6` and `robinraju/release-downloader@v1.7`.

Locations:

- `action.yml:15`
- `action.yml:35`

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

**Fixes applied:** unpinned-uses, script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed all findings in hardened/action/action.yml:
1. Pinned `actions/github-script@v6` to SHA `d7906e4ad0b1822421a7e6a35d5ca353c962f410` and `robinraju/release-downloader@v1.7` to SHA `768b85c8d69164800db5fc00337ab917daf3ce68`.
2. Moved all ${{ }} expressions out of run: shell strings into env: blocks: `runner.os` → `RUNNER_OS`, `inputs.version` → `INPUT_VERSION`, `steps.info.outputs.MINT_BINARY` → `MINT_BINARY`, `steps.info.outputs.MINT_PATH` → `MINT_PATH`.
3. Sanitized all values written to $GITHUB_OUTPUT and $GITHUB_PATH using `printf '%s' "$VAR" | tr -d '\n\r'` to prevent newline injection. The `working-directory:` field retains the expression since it is not a shell command and is not injectable in the same way.


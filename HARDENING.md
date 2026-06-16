<!-- markdownlint-disable -->

# Hardening Report: fabasoad--setup-mint-action/v1.2.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **fabasoad--setup-mint-action/v1.2.1** was hardened automatically. 7 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Multiple `${{ }}` expressions are interpolated directly inside `run:` shell command strings in the 'Collect info' step. Line 28: `if [ "${{ runner.os }}" = "Linux" ]` — runner.os is substituted before the shell sees the string. Lines 29 and 31: `MINT_BINARY=mint-${{ inputs.version }}-linux` / `-osx` — the user-controlled `inputs.version` value is injected directly into the shell command, allowing an attacker to supply a version string containing shell metacharacters (e.g. `;`, `$(...)`) to achieve command injection.

Locations:

- `action.yml:28`
- `action.yml:29`
- `action.yml:31`

### script-injection (severity: high)

Sub-rule (a): Multiple `${{ }}` expressions are interpolated directly inside `run:` shell command strings in the 'Install' step. Line 49: `mv ${{ steps.info.outputs.MINT_BINARY }} mint` — the step output is substituted before the shell parses the command. Line 51: `echo "${{ steps.info.outputs.MINT_PATH }}" >> $GITHUB_PATH` — the step output is substituted directly into the shell command. Both are unquoted/raw template substitutions that allow shell metacharacter injection.

Locations:

- `action.yml:49`
- `action.yml:51`

### github-env-injection (severity: high)

The 'Collect info' step writes `$MINT_BINARY` to `$GITHUB_OUTPUT` (line 33) without sanitization. `$MINT_BINARY` is derived from `${{ inputs.version }}` (lines 29/31), which is attacker-controlled. A newline embedded in `inputs.version` could inject arbitrary key=value pairs into GITHUB_OUTPUT. The required sanitization step (`printf '%s' "$MINT_BINARY" | tr -d '\n\r'`) is absent.

Locations:

- `action.yml:33`

### github-env-injection (severity: high)

The 'Install' step writes `${{ steps.info.outputs.MINT_PATH }}` directly to `$GITHUB_PATH` (line 51) without sanitization. A newline embedded in the step output value could inject arbitrary entries into GITHUB_PATH. The required sanitization step (`printf '%s' ... | tr -d '\n\r'`) is absent before the write.

Locations:

- `action.yml:51`

### unpinned-uses (severity: high)

Two `uses:` references in action.yml use mutable tag refs instead of pinned 40-character commit SHAs, making the action vulnerable to supply-chain attacks if the referenced tag is moved or the repository is compromised. Failing references: (1) `actions/github-script@v6` (line 17) — should be pinned to a full SHA such as `actions/github-script@60a0d83039c74a4aee543508d2ffcb1c3799cdea`. (2) `robinraju/release-downloader@v1.7` (line 37) — should be pinned to a full SHA.

Locations:

- `action.yml:17`
- `action.yml:37`

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

Fixed all findings in action.yml:
1. Pinned actions/github-script@v6 → @d7906e4ad0b1822421a7e6a35d5ca353c962f410 # v6
2. Pinned robinraju/release-downloader@v1.7 → @768b85c8d69164800db5fc00337ab917daf3ce68 # v1.7
3. Moved ${{ runner.os }} and ${{ inputs.version }} from 'Collect info' run: block into env: block (RUNNER_OS, INPUT_VERSION)
4. Moved ${{ steps.info.outputs.MINT_BINARY }} and ${{ steps.info.outputs.MINT_PATH }} from 'Install' run: block into env: block
5. Added tr -d '\n\r' sanitization for MINT_BINARY before writing to $GITHUB_OUTPUT
6. Added tr -d '\n\r' sanitization for MINT_PATH before writing to $GITHUB_PATH


<!-- markdownlint-disable -->

# Hardening Report: fabasoad--setup-mint-action/v1.3.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **fabasoad--setup-mint-action/v1.3.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

The 'Install' step in action.yml directly interpolates ${{ steps.info.outputs.MINT_BINARY }} and ${{ steps.info.outputs.MINT_PATH }} inside a run: shell block. These are steps.*.outputs.* context values — workflow-controllable — and are substituted by the Actions template engine before the shell ever sees them, enabling command injection. Offending lines: `mv "${{ steps.info.outputs.MINT_BINARY }}" mint` and `echo "${{ steps.info.outputs.MINT_PATH }}" >> "$GITHUB_PATH"`. These should be passed via env: variables and then double-quoted in the shell script.

Locations:

- `action.yml:43`
- `action.yml:45`

### github-env-injection (severity: high)

Multiple unsanitized writes to GitHub special environment files:

(1) action.yml 'Install' step: `echo "${{ steps.info.outputs.MINT_PATH }}" >> "$GITHUB_PATH"` writes a steps.*.outputs.* value directly to $GITHUB_PATH without the required `printf '%s' ... | tr -d '\n\r'` sanitization step.

(2) src/collect-info.sh: The variable $INPUT_VERSION (set from inputs.version by the calling step's env:) is used unsanitized to construct $MINT_BINARY, which is then written to $GITHUB_OUTPUT via `echo "MINT_BINARY=$MINT_BINARY" >> "$GITHUB_OUTPUT"`. An attacker-controlled version input containing newlines could inject arbitrary key=value pairs into GITHUB_OUTPUT.

(3) src/collect-info.sh: `echo "MINT_PATH=$GITHUB_WORKSPACE/mint" >> "$GITHUB_OUTPUT"` — $GITHUB_WORKSPACE is a workflow-controlled env var written to $GITHUB_OUTPUT without sanitization.

Locations:

- `action.yml:45`
- `src/collect-info.sh:15`
- `src/collect-info.sh:17`
- `src/collect-info.sh:37`

### unpinned-uses (severity: high)

The action uses `robinraju/release-downloader@v1.10` — a mutable tag reference rather than a full 40-character commit SHA. If the tag is moved or the repository is compromised, the action will silently execute different code. Pin to a specific commit SHA, e.g. `robinraju/release-downloader@<40-char-sha> # v1.10`.

Locations:

- `action.yml:32`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection, github-env-injection

**Notes:**

1. Pinned robinraju/release-downloader@v1.10 to full SHA c39a3b234af58f0cf85888573d361fb6fa281534 in action.yml. 2. Fixed script-injection in the Install step by moving steps.info.outputs.MINT_BINARY and steps.info.outputs.MINT_PATH into an env: block and referencing them as double-quoted shell variables. 3. Fixed github-env-injection: in action.yml Install step, sanitized MINT_PATH with printf|tr before writing to $GITHUB_PATH; in src/collect-info.sh, sanitized $GITHUB_WORKSPACE/mint before writing MINT_PATH to $GITHUB_OUTPUT, sanitized $INPUT_VERSION into safe_version before constructing MINT_BINARY, and sanitized MINT_BINARY before writing to $GITHUB_OUTPUT.


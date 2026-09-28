<!-- markdownlint-disable -->

# Hardening Report: fabasoad--setup-mint-action/v1.3.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **fabasoad--setup-mint-action/v1.3.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

The 'Install' step in action.yml directly interpolates ${{ }} expressions inside run: shell commands, violating rule (a). Specifically: `mv "${{ steps.info.outputs.MINT_BINARY }}" mint` and `echo "${{ steps.info.outputs.MINT_PATH }}" >> "$GITHUB_PATH"`. These step outputs originate from a script that processes the untrusted `inputs.version` value. Any ${{ }} expression inside a run: block is a script-injection risk because YAML template substitution occurs before the shell ever sees the string, allowing an attacker-controlled value to inject arbitrary shell commands.

Locations:

- `action.yml:44`
- `action.yml:45`

### github-env-injection (severity: high)

Untrusted values are written to special GitHub environment files without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). (1) action.yml 'Install' step: `echo "${{ steps.info.outputs.MINT_PATH }}" >> "$GITHUB_PATH"` — a step output (derived from the untrusted `inputs.version`) is written directly to GITHUB_PATH with no newline stripping. (2) src/collect-info.sh: `echo "MINT_BINARY=$MINT_BINARY" >> "$GITHUB_OUTPUT"` — $MINT_BINARY is constructed from $INPUT_VERSION (which is set from `inputs.version`, an untrusted composite-action input) without sanitization before being written to GITHUB_OUTPUT. A newline embedded in the version input could inject additional key=value pairs into the output file.

Locations:

- `action.yml:45`
- `src/collect-info.sh:35`

### unpinned-uses (severity: high)

The action.yml 'Download' step references `robinraju/release-downloader@v1.10`, which uses a mutable version tag rather than a pinned 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit at any time, making this a supply-chain risk. It should be pinned to a full SHA, e.g. `robinraju/release-downloader@<40-char-sha> # v1.10`.

Locations:

- `action.yml:31`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection, github-env-injection

**Notes:**

1. unpinned-uses (action.yml line 31): Pinned robinraju/release-downloader@v1.10 to full SHA @c39a3b234af58f0cf85888573d361fb6fa281534 # v1.10. 2. script-injection (action.yml lines 44-45): Moved ${{ steps.info.outputs.MINT_BINARY }} and ${{ steps.info.outputs.MINT_PATH }} out of the run: shell string into the step's env: block as MINT_BINARY and MINT_PATH, then referenced them as plain shell variables. 3. github-env-injection (action.yml line 45): Added sanitization of MINT_PATH via 'printf | tr -d' before writing to $GITHUB_PATH. In src/collect-info.sh line 35: Added sanitization of MINT_BINARY (and also MINT_PATH and MINT_INSTALLED) via 'printf | tr -d' before writing to $GITHUB_OUTPUT, preventing newline injection from the untrusted inputs.version value.


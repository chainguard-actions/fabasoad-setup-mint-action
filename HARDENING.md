<!-- markdownlint-disable -->

# Hardening Report: fabasoad--setup-mint-action/v1.3.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **fabasoad--setup-mint-action/v1.3.1** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

The 'Download' step uses `robinraju/release-downloader@v1.11`, which is pinned to a mutable version tag rather than an immutable 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling a supply-chain attack.

Locations:

- `action.yml:32`

### script-injection (severity: high)

Sub-rule (a): The 'Install' step's `run:` block directly interpolates GitHub Actions expressions into shell commands without going through an env: variable. `mv "${{ steps.info.outputs.mint-binary }}" mint` (line 44) and `echo "${{ steps.info.outputs.mint-path }}" >> "$GITHUB_PATH"` (line 46) both embed ${{ ... }} expressions directly in shell, allowing the value to be parsed by the YAML template engine before the shell ever sees it. If the output values contain shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.), they will be interpreted by the shell, enabling command injection.

Locations:

- `action.yml:44`
- `action.yml:46`

### github-env-injection (severity: high)

Unsanitized values derived from untrusted inputs are written to special GitHub environment files without the required `printf '%s' ... | tr -d '\n\r'` sanitization step:

1. action.yml line 46: `echo "${{ steps.info.outputs.mint-path }}" >> "$GITHUB_PATH"` writes a step output (itself derived from `inputs.version` via collect-info.sh) directly to $GITHUB_PATH. A newline embedded in the value would allow injecting arbitrary entries into $GITHUB_PATH.

2. src/collect-info.sh line 44: `echo "mint-binary=${mint_binary}" >> "$GITHUB_OUTPUT"` writes `mint_binary`, which is constructed from `input_version` (the caller-controlled `inputs.version` value passed as a positional argument). A newline in `inputs.version` would allow injecting arbitrary key=value pairs into $GITHUB_OUTPUT, potentially overwriting subsequent step outputs.

Locations:

- `action.yml:46`
- `src/collect-info.sh:44`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection, github-env-injection

**Notes:**

1. Pinned robinraju/release-downloader@v1.11 to full SHA a96f54c1b5f5e09e47d9504526e96febd949d4c2 in action.yml. 2. Moved ${{ steps.info.outputs.mint-binary }} and ${{ steps.info.outputs.mint-path }} into env vars (MINT_BINARY, MINT_PATH) in the Install step, eliminating direct expression interpolation in shell. 3. Added printf | tr -d '\n\r' sanitization for MINT_PATH before writing to $GITHUB_PATH in action.yml, and for mint_binary before writing to $GITHUB_OUTPUT in src/collect-info.sh.


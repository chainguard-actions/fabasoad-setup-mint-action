<!-- markdownlint-disable -->

# Hardening Report: fabasoad--setup-mint-action/v1.3.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **fabasoad--setup-mint-action/v1.3.1** was hardened automatically. 3 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Install' step's run block directly interpolates GitHub Actions expressions into shell commands. Line 42: `mv "${{ steps.info.outputs.mint-binary }}" mint` and line 44: `echo "${{ steps.info.outputs.mint-path }}" >> "$GITHUB_PATH"` both embed `${{ steps.info.outputs.* }}` expressions directly inside the shell script string. These values flow from user-controlled `inputs.version` through the collect-info.sh script and back into the shell without quoting protection at the YAML template level, allowing shell metacharacter injection before the shell ever sees the value.

Locations:

- `action.yml:42`
- `action.yml:44`

### github-env-injection (severity: high)

The 'Install' step writes `${{ steps.info.outputs.mint-path }}` directly to `$GITHUB_PATH` (line 44: `echo "${{ steps.info.outputs.mint-path }}" >> "$GITHUB_PATH"`) without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). The value of `steps.info.outputs.mint-path` is derived from `inputs.version` (a user-controlled input) and `$GITHUB_WORKSPACE`. Writing an unsanitized value to `$GITHUB_PATH` allows an attacker to inject newlines and manipulate the PATH for subsequent steps.

Locations:

- `action.yml:44`

### unpinned-uses (severity: high)

The 'Download' step references `robinraju/release-downloader@v1.11`, which is a mutable tag reference rather than an immutable 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling a supply-chain attack. It should be pinned to a full SHA, e.g. `robinraju/release-downloader@<40-char-sha> # v1.11`.

Locations:

- `action.yml:31`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection, github-env-injection

**Notes:**

Fixed three findings in action.yml: (1) Pinned robinraju/release-downloader@v1.11 to immutable SHA a96f54c1b5f5e09e47d9504526e96febd949d4c2. (2) Moved ${{ steps.info.outputs.mint-binary }} and ${{ steps.info.outputs.mint-path }} expressions out of the Install step's run block into an env: block as MINT_BINARY and MINT_PATH, then referenced them as plain shell variables. (3) Sanitized the MINT_PATH value before writing to $GITHUB_PATH using printf '%s' "$MINT_PATH" | tr -d '\n\r' to prevent newline injection.

### Iteration 2

**Fixes applied:** github-env-injection

**Notes:**

Fixed github-env-injection in src/collect-info.sh at line 44. The `mint_binary` value (derived from user-supplied `input_version`) is now sanitized before being written to $GITHUB_OUTPUT. Added `safe_mint_binary=$(printf '%s' "${mint_binary}" | tr -d '\n\r')` and changed the echo to use `safe_mint_binary` instead of `mint_binary` directly. This prevents an attacker from injecting additional key=value pairs into $GITHUB_OUTPUT by supplying a version string containing embedded newlines.


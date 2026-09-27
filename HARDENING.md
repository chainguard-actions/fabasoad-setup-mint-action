<!-- markdownlint-disable -->

# Hardening Report: fabasoad--setup-mint-action/v1.3.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **fabasoad--setup-mint-action/v1.3.2** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

The 'Download' step in action.yml uses `robinraju/release-downloader@v1`, which is pinned to a mutable tag rather than an immutable 40-character commit SHA. This means the action can be silently updated (or compromised) without any change to this repository, enabling supply-chain attacks.

Locations:

- `action.yml:30`

### script-injection (severity: high)

Sub-rule (a): The 'Install' step directly interpolates GitHub Actions expressions inside `run:` shell commands. Specifically, `${{ steps.info.outputs.mint-binary }}` is used in a `mv` command and `${{ steps.info.outputs.mint-path }}` is used in an `echo` command piped to $GITHUB_PATH. These step outputs are derived from `inputs.version` (user-controlled), so a crafted version string could inject arbitrary shell commands. The values must be passed via `env:` variables and then double-quoted in the shell script.

Locations:

- `action.yml:40`
- `action.yml:42`

### github-env-injection (severity: high)

The 'Install' step writes `${{ steps.info.outputs.mint-path }}` directly to $GITHUB_PATH without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). The value is derived from `inputs.version` (user-controlled via the calling workflow), so a newline-containing version string could inject arbitrary entries into $GITHUB_PATH or poison subsequent environment-file writes. Additionally, in src/collect-info.sh, the `mint_binary` variable (constructed from `input_version`, which comes from `inputs.version`) is written to $GITHUB_OUTPUT without sanitization, allowing a crafted version string to inject additional key=value pairs into the output file.

Locations:

- `action.yml:42`
- `src/collect-info.sh:48`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection, github-env-injection

**Notes:**

1. Pinned robinraju/release-downloader@v1 to full commit SHA 28fc21f50d76778e7023361aa1f863e717d3d56f in action.yml. 2. Moved ${{ steps.info.outputs.mint-binary }} and ${{ steps.info.outputs.mint-path }} expressions from inline run: shell commands into an env: block (as MINT_BINARY and MINT_PATH), then referenced them as double-quoted shell variables. 3. Added sanitization via 'printf "%s" | tr -d "\n\r"' before writing MINT_PATH to $GITHUB_PATH in action.yml, and added the same sanitization before writing mint-binary to $GITHUB_OUTPUT in src/collect-info.sh.


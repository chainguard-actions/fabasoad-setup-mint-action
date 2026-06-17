<!-- markdownlint-disable -->

# Hardening Report: fabasoad--setup-mint-action/v1.3.2

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **fabasoad--setup-mint-action/v1.3.2** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

The 'Install' step in action.yml directly interpolates ${{ steps.info.outputs.mint-binary }} and ${{ steps.info.outputs.mint-path }} inside run: shell commands (sub-rule a). These step outputs are derived from inputs.version (user-controlled), so an attacker can inject arbitrary shell metacharacters. Offending lines:
  mv "${{ steps.info.outputs.mint-binary }}" mint
  echo "${{ steps.info.outputs.mint-path }}" >> "$GITHUB_PATH"
  working-directory: ${{ steps.info.outputs.mint-path }}
All ${{ }} expressions must be moved to env: variables and then double-quoted in the shell script.

Locations:

- `action.yml:40`
- `action.yml:42`
- `action.yml:43`

### github-env-injection (severity: high)

Two unsanitized writes to GitHub special environment files were found:

(1) action.yml 'Install' step (line 42): `echo "${{ steps.info.outputs.mint-path }}" >> "$GITHUB_PATH"` writes a ${{ }} expression derived from user-controlled inputs.version directly to $GITHUB_PATH without the required `printf '%s' ... | tr -d '\n\r'` sanitization step.

(2) src/collect-info.sh (line 48): `echo "mint-binary=${mint_binary}" >> "$GITHUB_OUTPUT"` writes mint_binary to $GITHUB_OUTPUT, where mint_binary is constructed directly from input_version (which is inputs.version passed by the caller) without any newline sanitization. A malicious version string containing newlines could inject additional key=value pairs into $GITHUB_OUTPUT.

Locations:

- `action.yml:42`
- `src/collect-info.sh:48`

### unpinned-uses (severity: high)

The 'Download' step uses `robinraju/release-downloader@v1`, which is a mutable tag reference rather than a pinned 40-character commit SHA. If the tag is moved or the repository is compromised, a different (potentially malicious) version of the action could be executed. It should be pinned to a full SHA, e.g. `robinraju/release-downloader@<40-char-sha> # v1`.

Locations:

- `action.yml:30`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection, github-env-injection

**Notes:**

1. Pinned robinraju/release-downloader@v1 to full SHA 28fc21f50d76778e7023361aa1f863e717d3d56f with # v1 comment. 2. Moved ${{ steps.info.outputs.mint-binary }} and ${{ steps.info.outputs.mint-path }} from inline run: shell commands into the step's env: block as MINT_BINARY and MINT_PATH, then referenced them as plain shell variables. 3. Added printf '%s' ... | tr -d '\n\r' sanitization before writing MINT_PATH to $GITHUB_PATH in action.yml. 4. Added printf '%s' ... | tr -d '\n\r' sanitization before writing mint_binary to $GITHUB_OUTPUT in src/collect-info.sh. The working-directory field still uses ${{ steps.info.outputs.mint-path }} as it is a YAML field (not a shell command) and is not subject to shell injection.


<!-- markdownlint-disable -->

# Hardening Report: fabasoad--setup-mint-action/v1.4.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **fabasoad--setup-mint-action/v1.4.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The 'Install mint' step's `run:` block directly interpolates `${{ ... }}` expressions inside shell commands. Specifically: `tag_name="${{ steps.download-binary.outputs.tag_name }}"` and `mv "mint-${tag_name}-${{ runner.os == 'Linux' && 'linux' || 'osx' }}-${{ startsWith(runner.arch, 'ARM') && 'arm64' || 'x86_64' }}" mint`. These expressions are substituted by the YAML template engine before the shell ever parses the command, allowing injected content (e.g. a malicious tag_name containing shell metacharacters) to execute arbitrary commands. All `${{ ... }}` in `run:` blocks are script-injection risks and must be moved to `env:` variables and then double-quoted in the shell.

Locations:

- `action.yml:52`
- `action.yml:53`

### unpinned-uses (severity: high)

The action uses `robinraju/release-downloader@v1`, which is pinned to a mutable tag (`v1`) rather than an immutable 40-character commit SHA. A compromised or updated tag could silently introduce malicious code into the action's supply chain. Pin to a full SHA, e.g. `robinraju/release-downloader@<40-char-sha> # v1`.

Locations:

- `action.yml:44`

### github-env-injection (severity: high)

In `src/collect-info.sh`, the variable `bin_path` is constructed as `"$GITHUB_WORKSPACE/${bin_dir}"` and then written directly to `$GITHUB_OUTPUT` via `echo "bin-path=${bin_path}" >> "$GITHUB_OUTPUT"`. `$GITHUB_WORKSPACE` is an inherited process environment variable set by the calling workflow and must be treated as untrusted (workflow-controlled). No sanitization (`printf '%s' ... | tr -d '\n\r'`) is applied before the write, so a newline embedded in `$GITHUB_WORKSPACE` could inject additional key=value pairs into `$GITHUB_OUTPUT`, potentially overwriting other outputs.

Locations:

- `src/collect-info.sh:26`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection, github-env-injection

**Notes:**

1. Pinned robinraju/release-downloader@v1 to full SHA 28fc21f50d76778e7023361aa1f863e717d3d56f with # v1 comment in action.yml line 44. 2. Moved ${{ steps.download-binary.outputs.tag_name }}, ${{ runner.os == 'Linux' && 'linux' || 'osx' }}, and ${{ startsWith(runner.arch, 'ARM') && 'arm64' || 'x86_64' }} expressions from the 'Install mint' run: block into an env: block as TAG_NAME, RUNNER_OS_LABEL, and RUNNER_ARCH_LABEL; the shell script now references these as plain environment variables. 3. In src/collect-info.sh, sanitized bin_path before writing to $GITHUB_OUTPUT using printf '%s' ... | tr -d '\n\r' to prevent newline injection.


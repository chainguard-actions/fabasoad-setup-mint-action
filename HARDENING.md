<!-- markdownlint-disable -->

# Hardening Report: fabasoad--setup-mint-action/v1.4.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **fabasoad--setup-mint-action/v1.4.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

The composite action uses `robinraju/release-downloader@v1`, which is pinned to a mutable tag (`v1`) rather than an immutable 40-character commit SHA. If the tag is moved (e.g. by a supply-chain compromise of that repository), the action will silently execute different code. Pin to a full SHA, e.g. `robinraju/release-downloader@<40-char-sha> # v1`.

Locations:

- `action.yml:46`

### script-injection (severity: high)

Sub-rule (a): The 'Install mint' step's `run:` block directly interpolates GitHub Actions expressions inside shell command strings. The YAML template engine substitutes these values before the shell parses the script, allowing an attacker-controlled value to inject arbitrary shell commands. Offending lines:
  - `tag_name="${{ steps.download-binary.outputs.tag_name }}"` — the tag_name output from the downloader step is interpolated directly into the shell.
  - `mv "mint-${tag_name}-${{ runner.os == 'Linux' && 'linux' || 'osx' }}-${{ startsWith(runner.arch, 'ARM') && 'arm64' || 'x86_64' }}" mint` — runner context expressions are interpolated directly into the shell command.
Fix: move all `${{ ... }}` values into `env:` variables and reference them as quoted shell variables (e.g. `"$TAG_NAME"`, `"$RUNNER_OS_LABEL"`).

Locations:

- `action.yml:56`
- `action.yml:57`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, script-injection

**Notes:**

1. Pinned robinraju/release-downloader@v1 to full SHA 28fc21f50d76778e7023361aa1f863e717d3d56f with '# v1' comment. 2. Fixed script-injection in the 'Install mint' step by moving ${{ steps.download-binary.outputs.tag_name }}, ${{ runner.os == 'Linux' && 'linux' || 'osx' }}, and ${{ startsWith(runner.arch, 'ARM') && 'arm64' || 'x86_64' }} into env: variables (TAG_NAME, RUNNER_OS_LABEL, RUNNER_ARCH_LABEL) and referencing them as quoted shell variables in the run: block.


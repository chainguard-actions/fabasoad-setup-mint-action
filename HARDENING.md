<!-- markdownlint-disable -->

# Hardening Report: fabasoad--setup-mint-action/v1.4.1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **fabasoad--setup-mint-action/v1.4.1** was hardened automatically. 4 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): A ${{ }} expression is directly interpolated inside a run: shell command string in the 'Prepare binary name template' step. The expression `${{ format('{0}-{1}', case(runner.os == 'macOS', 'osx', 'linux'), case(startsWith(runner.arch, 'ARM'), 'arm64', 'x86_64')) }}` is substituted into the shell script before the shell parses it, allowing YAML-template injection. Any ${{ }} in a run: block is a script-injection risk regardless of which context it reads from.

Locations:

- `action.yml:51`

### script-injection (severity: high)

Sub-rule (a): A ${{ }} expression is directly interpolated inside a run: shell command string in the 'Install mint' step. The expression `${{ format(steps.binary-name.outputs.template, steps.download-binary.outputs.tag_name) }}` reads from `steps.*.outputs.*`, which is explicitly listed as an untrusted/workflow-controllable context, and is substituted directly into the shell command `mv "${{ ... }}" mint` before the shell parses it.

Locations:

- `action.yml:74`

### github-env-injection (severity: high)

In the 'Prepare binary name template' step, the shell variable `template` is assigned a value that includes a directly-interpolated `${{ format(..., runner.os, runner.arch) }}` expression (line 51). This value is then written to $GITHUB_OUTPUT via `echo "template=${template}" >> "$GITHUB_OUTPUT"` without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). An attacker-influenced or malformed value in the expression output could inject newlines into the output file, enabling environment variable injection.

Locations:

- `action.yml:55`

### unpinned-uses (severity: high)

The action uses `robinraju/release-downloader@v1`, which is pinned to a mutable version tag rather than an immutable 40-character commit SHA. A tag can be moved to point to a different (potentially malicious) commit, enabling a supply-chain attack. It should be pinned to a full SHA, e.g. `robinraju/release-downloader@<40-char-sha> # v1`.

Locations:

- `action.yml:61`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, unpinned-uses

**Notes:**

Fixed all four findings in hardened/action/action.yml:
1. script-injection (line 51): Moved `${{ format('{0}-{1}', case(runner.os == 'macOS', 'osx', 'linux'), case(startsWith(runner.arch, 'ARM'), 'arm64', 'x86_64')) }}` into an env var `BINARY_OS_ARCH` and referenced it as `${BINARY_OS_ARCH}` in the shell script.
2. github-env-injection (line 55): Added `safe=$(printf '%s' "${template}" | tr -d '\n\r')` sanitization before writing to $GITHUB_OUTPUT.
3. script-injection (line 74): Moved `${{ format(steps.binary-name.outputs.template, steps.download-binary.outputs.tag_name) }}` into an env var `BINARY_FILENAME` and referenced it as `"${BINARY_FILENAME}"` in the shell script.
4. unpinned-uses (line 61): Pinned `robinraju/release-downloader@v1` to full SHA `28fc21f50d76778e7023361aa1f863e717d3d56f` with `# v1` comment.


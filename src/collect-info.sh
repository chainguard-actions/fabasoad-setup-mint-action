#!/usr/bin/env sh

# Starting from v0.20.0-alpha.1 mint supports macos arm64 OS. This function
# checks if requested version is less than 0.20.x
if_old_version() {
  version="$1"
  major=$(echo "$version" | cut -d '.' -f 1)
  minor=$(echo "$version" | cut -d '.' -f 2)
  if [ "$major" -lt 1 ] && [ "$minor" -lt 20 ]; then
    echo "true"
  else
    echo "false"
  fi
}

MINT_INSTALLED_VAL=$(if command -v mint > /dev/null 2>&1; then echo true; else echo false; fi)
safe_installed=$(printf '%s' "$MINT_INSTALLED_VAL" | tr -d '\n\r')
echo "MINT_INSTALLED=$safe_installed" >> "$GITHUB_OUTPUT"
mkdir -p "$GITHUB_WORKSPACE/mint"
safe_mint_path=$(printf '%s' "$GITHUB_WORKSPACE/mint" | tr -d '\n\r')
echo "MINT_PATH=$safe_mint_path" >> "$GITHUB_OUTPUT"
if [ "${RUNNER_OS}" = "Linux" ]; then
  MINT_BINARY=mint-${INPUT_VERSION}-linux
else
  if [ "${RUNNER_ARCH#ARM}" != "$RUNNER_ARCH" ]; then
    if [ "$(if_old_version "${INPUT_VERSION}")" = "true" ]; then
      msg="${RUNNER_OS} ${RUNNER_ARCH} is not supported by mint ${INPUT_VERSION}."
      msg="${msg} Try newer version of mint (> 0.19.x)."
      echo "::error title=OS is not supported::${msg}"
      exit 1
    else
      MINT_BINARY=mint-${INPUT_VERSION}-macos-latest
    fi
  else
    if [ "$(if_old_version "${INPUT_VERSION}")" = "true" ]; then
      MINT_BINARY=mint-${INPUT_VERSION}-osx
    else
      MINT_BINARY=mint-${INPUT_VERSION}-macos-13
    fi
  fi
fi
safe_mint_binary=$(printf '%s' "$MINT_BINARY" | tr -d '\n\r')
echo "MINT_BINARY=$safe_mint_binary" >> "$GITHUB_OUTPUT"

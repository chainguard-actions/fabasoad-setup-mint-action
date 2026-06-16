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

echo "MINT_INSTALLED=$(if command -v mint >/dev/null 2>&1; then echo true; else echo false; fi)" >> "$GITHUB_OUTPUT"
mkdir -p "$GITHUB_WORKSPACE/mint"
safe_mint_path=$(printf '%s' "$GITHUB_WORKSPACE/mint" | tr -d '\n\r')
echo "MINT_PATH=$safe_mint_path" >> "$GITHUB_OUTPUT"
safe_version=$(printf '%s' "$INPUT_VERSION" | tr -d '\n\r')
if [ "${RUNNER_OS}" = "Linux" ]; then
  MINT_BINARY=mint-${safe_version}-linux
else
  if [ "${RUNNER_ARCH#ARM}" != "$RUNNER_ARCH" ]; then
    if [ "$(if_old_version "${safe_version}")" = "true" ]; then
      msg="${RUNNER_OS} ${RUNNER_ARCH} is not supported by mint ${safe_version}."
      msg="${msg} Try newer version of mint (> 0.19.x)."
      echo "::error title=OS is not supported::${msg}"
      exit 1
    else
      MINT_BINARY=mint-${safe_version}-macos-latest
    fi
  else
    if [ "$(if_old_version "${safe_version}")" = "true" ]; then
      MINT_BINARY=mint-${safe_version}-osx
    else
      MINT_BINARY=mint-${safe_version}-macos-13
    fi
  fi
fi
safe_mint_binary=$(printf '%s' "$MINT_BINARY" | tr -d '\n\r')
echo "MINT_BINARY=$safe_mint_binary" >> "$GITHUB_OUTPUT"

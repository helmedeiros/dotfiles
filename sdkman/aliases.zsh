# shellcheck shell=bash
#
# Java version-switcher aliases, rewired through SDKMAN.
#
# The old java/aliases.zsh hardcoded specific patch versions
# (1.8.0_282, 11.0.10, 13.0.2, 14.0.2) against /usr/libexec/java_home.
# That broke silently every time a JDK was upgraded.
#
# These aliases delegate to `sdk use`, which picks the newest installed
# minor of each major. Install the majors with:
#   sdk install java 8.0.412-tem
#   sdk install java 11.0.24-tem
#   sdk install java 17.0.12-tem
#   sdk install java 21.0.4-tem    # already installed by sdkman/install.sh
#
# Then `java21` (etc.) flips the active JDK for the current shell.

_sdk_use_java_major() {
  local major="$1"
  if ! command -v sdk >/dev/null 2>&1; then
    # Trigger the lazy loader in sdkman/path.zsh.
    sdk version >/dev/null 2>&1
  fi
  local installed
  installed=$(sdk list java 2>/dev/null \
    | awk -v m="${major}" '$NF ~ "^"m"\\." && $0 ~ "installed" {print $NF; exit}')
  if [[ -z "$installed" ]]; then
    echo "No Java ${major}.x installed via SDKMAN. Try: sdk install java ${major}-tem" >&2
    return 1
  fi
  sdk use java "$installed"
}

alias java8='_sdk_use_java_major 8'
alias java11='_sdk_use_java_major 11'
alias java17='_sdk_use_java_major 17'
alias java21='_sdk_use_java_major 21'

# shellcheck shell=bash
#
# SDKMAN owns the JVM toolchain: Java (Temurin), Gradle, Maven, Groovy,
# and anything else added via `sdk install`. Versions are switched with
# `sdk use <candidate> <version>` (or pinned per-project in `.sdkmanrc`).
#
# Lazy-loaded so it doesn't add ~250ms to every shell startup. The first
# invocation of `sdk`, `java`, `gradle`, `mvn`, or `groovy` sources
# sdkman-init.sh and re-execs the real command. After that, JAVA_HOME +
# PATH are set and everything works directly.

export SDKMAN_DIR="$HOME/.sdkman"

if [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
  # Eagerly expose the current default JDK on PATH so JAVA_HOME-aware
  # tools (and the p10k java_version segment) work without paying the
  # full sdkman-init.sh cost yet. SDKMAN symlinks ~/.sdkman/candidates/
  # java/current at the active version.
  if [[ -d "$SDKMAN_DIR/candidates/java/current" ]]; then
    export JAVA_HOME="$SDKMAN_DIR/candidates/java/current"
    export PATH="$JAVA_HOME/bin:$PATH"
  fi

  _sdkman_lazy_load() {
    unset -f sdk java javac jar gradle mvn groovy 2>/dev/null
    # shellcheck disable=SC1091
    source "$SDKMAN_DIR/bin/sdkman-init.sh"
  }

  sdk()    { _sdkman_lazy_load && sdk "$@"; }
  gradle() { _sdkman_lazy_load && gradle "$@"; }
  mvn()    { _sdkman_lazy_load && mvn "$@"; }
  groovy() { _sdkman_lazy_load && groovy "$@"; }
fi

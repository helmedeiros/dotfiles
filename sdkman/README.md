# SDKMAN

[SDKMAN!](https://sdkman.io) owns the JVM toolchain in this dotfiles repo
— Java, Gradle, Maven, Groovy, and any other JVM CLI you install
on top (Kotlin, Scala, Spring Boot CLI, etc.). It replaces the previous
mix of:

- `cask 'temurin@17'` / `cask 'temurin@21'` from the Brewfile
- `brew 'gradle'` / `brew 'maven'` / `brew 'groovy'`
- `java/`, `gradle/path.zsh`, `groovy/`, `springboot-cli/` topic dirs
- Hand-rolled `JAVA_HOME_8` / `JAVA_HOME_11` aliases that hardcoded
  patch versions and silently rotted on every JDK update

## What `install.sh` does

1. Downloads the SDKMAN bootstrap installer from `get.sdkman.io` with a
   pinned SHA-256 (via `lib/integrity.sh`) and runs it. The
   `?rcupdate=false` query string tells SDKMAN not to mangle
   `~/.zshrc` — shell init lives in `sdkman/path.zsh`.
2. Installs the default JDK (`21-tem`) plus `gradle`, `maven`,
   `groovy` — latest stable of each.
3. Drops `org.gradle.daemon=true` into `~/.gradle/gradle.properties`.

Re-running is a no-op: SDKMAN itself, individual candidates, and the
gradle daemon flag are all checked before reinstall.

## Day-to-day usage

```sh
sdk list java                 # see available JDKs
sdk install java 17.0.12-tem  # install a specific build
sdk use java 17.0.12-tem      # switch the current shell
sdk default java 21.0.4-tem   # change the global default
sdk current                   # what's active right now
```

For per-project pinning, drop a `.sdkmanrc` at the project root:

```
java=21.0.4-tem
gradle=8.10
```

`sdk env install` reads it; `sdk env` switches the shell to match.

### Java major-version aliases

`sdkman/aliases.zsh` keeps the old workflow alive: `java8`, `java11`,
`java17`, `java21` each call `sdk use java <newest-installed-of-that-major>`.
They print a helpful hint if the major isn't installed yet.

## What gets loaded into your shell

- `path.zsh` — exports `SDKMAN_DIR`, eagerly exposes the current default
  JDK on `PATH`/`JAVA_HOME`, and lazy-loads `sdkman-init.sh` on first
  use of `sdk` / `gradle` / `mvn` / `groovy`. Saves ~250ms of shell
  startup vs. always sourcing.
- `aliases.zsh` — `java8` / `java11` / `java17` / `java21`.

## Rotating the pinned SHA

```sh
curl -fsSL "https://get.sdkman.io/?rcupdate=false" | shasum -a 256
```

Paste the new value into `SDKMAN_INSTALLER_SHA256` in `install.sh`.
Tests in `test/sdkman/install_test.bats` enforce that the constant
keeps its 64-hex-char shape.

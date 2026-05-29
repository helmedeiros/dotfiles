# Gradle

[Gradle](https://gradle.org) configuration helpers. Gradle itself is installed via the Brewfile.

## What `install.sh` does

Writes `org.gradle.daemon=true` into `~/.gradle/gradle.properties` so the Gradle daemon stays warm between invocations.

## What gets loaded into your shell

- `aliases.zsh` — Gradle wrapper / task shortcuts.
- `path.zsh` — exposes Gradle helpers on `PATH`.

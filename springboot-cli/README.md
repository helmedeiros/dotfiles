# Spring Boot CLI

[Spring Cloud CLI](https://github.com/spring-cloud/spring-cloud-cli) plugin for the Spring Boot CLI.

## What `install.sh` does

If `~/spring-cloud-cli` exists, clones the repo and runs `mvn install` + `spring install` to register the Spring Cloud CLI plugin. Note: the Spring Boot CLI itself is no longer in Homebrew (entry commented out in the Brewfile), so this directory is largely vestigial — install Spring Boot CLI manually if you need it.

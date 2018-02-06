#!/bin/sh
#
# Spring Boot and Cloud Cli
set -e

# Check for springboot
if [ -f ~/spring-cloud-cli ]
then
  echo "  Installing spring cloud cli for you."
  git clone https://github.com/spring-cloud/spring-cloud-cli ~/spring-cloud-cli &&
  cd ~/spring-cloud-cli  && mvn install && spring install org.springframework.cloud:spring-cloud-cli:1.4.0.BUILD-SNAPSHOT
fi

#!/bin/sh
#
# Gradle
#
# This Activate Gradle Daemon and other configurations

# Check for Gradle
if test $(which gradle)
then
  echo "  Enablig Gradle Daemon."
  mkdir -p ~/.gradle && touch ~/.gradle/gradle.properties && echo "org.gradle.daemon=true" >> ~/.gradle/gradle.properties
fi
exit 

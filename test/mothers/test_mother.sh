#!/bin/bash
#
# test_mother.sh
#
# Main Object Mother for test fixtures

# Load the individual mothers
source "$(dirname "${BASH_SOURCE[0]}")/git_mother.sh"
source "$(dirname "${BASH_SOURCE[0]}")/brew_mother.sh"
source "$(dirname "${BASH_SOURCE[0]}")/npm_mother.sh"
source "$(dirname "${BASH_SOURCE[0]}")/dot_mother.sh"

# Function to set up a test environment with the specified fixtures
a_scenario_with() {
  local test_dir="$1"
  local git_fixture="$2"
  local brew_fixture="$3"
  local npm_fixture="$4"
  local dot_fixture="$5"

  # Create the test directory structure
  mkdir -p "${test_dir}"
  mkdir -p "${test_dir}/dotfiles"
  mkdir -p "${test_dir}/dotfiles/.git"
  mkdir -p "${test_dir}/dotfiles/lib"

  # Set up the git fixture
  case "$git_fixture" in
    "upToDateRepository")
      a_git_repository_up_to_date "$test_dir"
      ;;
    "repositoryBehindRemote")
      a_git_repository_behind_remote "$test_dir"
      ;;
    "repositoryWithLocalChanges")
      a_git_repository_with_local_changes "$test_dir"
      ;;
    "repositoryDivergedFromRemote")
      a_git_repository_diverged_from_remote "$test_dir"
      ;;
    *)
      git_mother_create_mock "$test_dir" "local-hash" "remote-hash" "base-hash"
      ;;
  esac

  # Set up the brew fixture
  case "$brew_fixture" in
    "brewWithNoOutdatedPackages")
      a_brew_with_no_outdated_packages "$test_dir"
      ;;
    "brewWithOutdatedPackages")
      a_brew_with_outdated_packages "$test_dir"
      ;;
    *)
      a_brew_with_outdated_packages "$test_dir"  # Default to brewWithOutdatedPackages
      ;;
  esac

  # Set up the npm fixture
  case "$npm_fixture" in
    "npmWithNoOutdatedPackages")
      an_npm_with_no_outdated_packages "$test_dir"
      ;;
    "npmWithOutdatedPackages")
      an_npm_with_outdated_packages "$test_dir"
      ;;
    *)
      an_npm_with_outdated_packages "$test_dir"  # Default to npmWithOutdatedPackages
      ;;
  esac

  # Set up the dot fixture
  case "$dot_fixture" in
    "standardDotScript")
      a_standard_dot_script "$test_dir"
      ;;
    *)
      a_standard_dot_script "$test_dir"  # Default to standardDotScript
      ;;
  esac

  # Add the mock bin directory to the PATH
  export PATH="${test_dir}/bin:${PATH}"
}

# Create standard test scenarios

# Scenario 1: Everything is up to date
# Repository up to date + Brew up to date + NPM up to date + Standard dot script
an_up_to_date_scenario() {
  local test_dir="$1"
  a_scenario_with "$test_dir" "upToDateRepository" "brewWithNoOutdatedPackages" "npmWithNoOutdatedPackages" "standardDotScript"
}

# Scenario 2: Dotfiles need update
# Repository behind remote + Brew outdated + NPM outdated + Standard dot script
a_needs_update_scenario() {
  local test_dir="$1"
  a_scenario_with "$test_dir" "repositoryBehindRemote" "brewWithOutdatedPackages" "npmWithOutdatedPackages" "standardDotScript"
}

# Scenario 3: Local changes
# Repository with local changes + Brew outdated + NPM outdated + Standard dot script
a_local_changes_scenario() {
  local test_dir="$1"
  a_scenario_with "$test_dir" "repositoryWithLocalChanges" "brewWithOutdatedPackages" "npmWithOutdatedPackages" "standardDotScript"
}

# Scenario 4: Diverged repository
# Repository diverged from remote + Brew outdated + NPM outdated + Standard dot script
a_diverged_scenario() {
  local test_dir="$1"
  a_scenario_with "$test_dir" "repositoryDivergedFromRemote" "brewWithOutdatedPackages" "npmWithOutdatedPackages" "standardDotScript"
}

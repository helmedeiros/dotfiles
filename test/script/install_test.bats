#!/usr/bin/env bats
#
# script/install runs every topic installer. A failure must not stop the rest,
# but it must not disappear either — the previous version printed one line and
# discarded the exit code, so a topic that never installed was indistinguishable
# from one that did.

bats_require_minimum_version 1.5.0

setup() {
  TEST_DIR="$(mktemp -d)"
  cp "${BATS_TEST_DIRNAME}/../../script/install" "${TEST_DIR}/install"
  chmod +x "${TEST_DIR}/install"
  mkdir -p "${TEST_DIR}/script"
  mv "${TEST_DIR}/install" "${TEST_DIR}/script/install"
}

teardown() {
  rm -rf "${TEST_DIR}"
}

# Each topic writes its name to a log, so we can prove which ones actually ran.
a_topic() {
  mkdir -p "${TEST_DIR}/$1"
  cat > "${TEST_DIR}/$1/install.sh" <<EOF
#!/bin/sh
echo "$1" >> "${TEST_DIR}/ran.log"
exit ${2:-0}
EOF
  chmod +x "${TEST_DIR}/$1/install.sh"
}

@test "runs every installer and succeeds when all pass" {
  a_topic alpha
  a_topic beta

  run "${TEST_DIR}/script/install"

  [ "$status" -eq 0 ]
  [[ "$output" == *"Post-install scripts completed"* ]]
  grep -q alpha "${TEST_DIR}/ran.log"
  grep -q beta "${TEST_DIR}/ran.log"
}

@test "a failing installer does not stop the others" {
  a_topic alpha 1
  a_topic beta 0

  run "${TEST_DIR}/script/install"

  # beta must still have run despite alpha failing.
  grep -q beta "${TEST_DIR}/ran.log"
}

@test "reports which installers failed and exits non-zero" {
  a_topic alpha 1
  a_topic beta 0
  a_topic gamma 1

  run "${TEST_DIR}/script/install"

  [ "$status" -ne 0 ]
  [[ "$output" == *"2 of 3 post-install scripts failed"* ]]
  [[ "$output" == *"alpha"* ]]
  [[ "$output" == *"gamma"* ]]
}

@test "does not claim completion when something failed" {
  a_topic alpha 1

  run "${TEST_DIR}/script/install"

  [[ "$output" != *"Post-install scripts completed"* ]]
}

@test "handles a path containing spaces" {
  # The old word-splitting loop turned one such path into two missing scripts.
  a_topic "with space"

  run "${TEST_DIR}/script/install"

  [ "$status" -eq 0 ]
  grep -q "with space" "${TEST_DIR}/ran.log"
}

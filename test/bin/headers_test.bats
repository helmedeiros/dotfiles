#!/usr/bin/env bats

# Path to the script being tested
HEADERS_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/headers"

# Setup function that runs before each test
setup() {
  # Create a temporary directory for test files
  TEST_DIR="$(mktemp -d)"

  # Save the current directory to return to it later
  ORIGINAL_DIR="$(pwd)"

  # Create a mock curl command
  MOCK_CURL="${TEST_DIR}/bin/curl"
  mkdir -p "${TEST_DIR}/bin"

  # Add mock bin to PATH
  export PATH="${TEST_DIR}/bin:${PATH}"
}

# Teardown function that runs after each test
teardown() {
  # Return to the original directory
  cd "${ORIGINAL_DIR}"

  # Clean up the temporary directory
  rm -rf "${TEST_DIR}"
}

# Helper function to create a mock curl that simulates successful response
create_mock_curl_success() {
  cat > "${MOCK_CURL}" <<'EOF'
#!/bin/bash
# Mock curl that simulates a successful HTTP request

# Check if -sv flags are present (verbose mode)
if [[ "$*" == *"-sv"* ]]; then
  # Simulate curl verbose output to stderr
  cat >&2 <<'CURL_OUTPUT'
* Connected to example.com (93.184.216.34) port 443 (#0)
* ALPN, offering h2
* ALPN, offering http/1.1
> GET / HTTP/2
> Host: example.com
> User-Agent: curl/7.79.1
> Accept: */*
>
< HTTP/2 200
< age: 347032
< cache-control: max-age=604800
< content-type: text/html; charset=UTF-8
< date: Mon, 14 Oct 2024 01:00:00 GMT
< etag: "3147526947+ident"
< expires: Mon, 21 Oct 2024 01:00:00 GMT
< last-modified: Thu, 17 Oct 2019 07:18:26 GMT
< server: ECS (nyb/1D18)
< x-cache: HIT
< content-length: 1256
<
* Connection #0 to host example.com left intact
CURL_OUTPUT
  exit 0
else
  # Non-verbose mode
  echo "Use -sv for headers"
  exit 0
fi
EOF
  chmod +x "${MOCK_CURL}"
}

# Helper function to create a mock curl that simulates a failed request
create_mock_curl_error() {
  cat > "${MOCK_CURL}" <<'EOF'
#!/bin/bash
# Mock curl that simulates a failed HTTP request

cat >&2 <<'CURL_OUTPUT'
* Could not resolve host: invalid-domain-that-does-not-exist.com
* Closing connection 0
curl: (6) Could not resolve host: invalid-domain-that-does-not-exist.com
CURL_OUTPUT
exit 6
EOF
  chmod +x "${MOCK_CURL}"
}

# Helper function to create a mock curl with custom headers
create_mock_curl_with_custom_headers() {
  cat > "${MOCK_CURL}" <<'EOF'
#!/bin/bash
# Mock curl that includes custom headers in output

cat >&2 <<'CURL_OUTPUT'
* Connected to api.example.com (93.184.216.34) port 443 (#0)
> POST /api/endpoint HTTP/2
> Host: api.example.com
> User-Agent: curl/7.79.1
> Accept: */*
> Content-Type: application/json
> Authorization: Bearer token123
> Content-Length: 16
>
< HTTP/2 201
< content-type: application/json
< date: Mon, 14 Oct 2024 01:00:00 GMT
< server: nginx/1.18.0
< x-request-id: abc-123-def-456
< content-length: 45
<
* Connection #0 to host api.example.com left intact
CURL_OUTPUT
exit 0
EOF
  chmod +x "${MOCK_CURL}"
}

# Test that the script exists and is executable
@test "headers script exists and is executable" {
  [ -f "${HEADERS_SCRIPT}" ]
  [ -x "${HEADERS_SCRIPT}" ]
}

# Test showing help message with -h
@test "headers -h shows help message" {
  run "${HEADERS_SCRIPT}" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"DESCRIPTION"* ]]
  [[ "$output" == *"USAGE"* ]]
  [[ "$output" == *"OPTIONS"* ]]
  [[ "$output" == *"EXAMPLES"* ]]
}

# Test showing help message with --help
@test "headers --help shows help message" {
  run "${HEADERS_SCRIPT}" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"DESCRIPTION"* ]]
  [[ "$output" == *"headers [options] URL"* ]]
}

# Test default behavior (response headers only)
@test "headers shows only response headers by default" {
  create_mock_curl_success

  run "${HEADERS_SCRIPT}" https://example.com
  [ "$status" -eq 0 ]

  # Should include response headers
  [[ "$output" == *"HTTP/2 200"* ]]
  [[ "$output" == *"content-type: text/html"* ]]
  [[ "$output" == *"server: ECS"* ]]

  # Should NOT include request headers (lines with >)
  [[ "$output" != *"> GET"* ]]
  [[ "$output" != *"> Host:"* ]]
  [[ "$output" != *"> User-Agent:"* ]]

  # Should include the response headers label
  [[ "$output" == *"=== RESPONSE HEADERS ==="* ]]
}

# Test -i flag includes both request and response headers
@test "headers -i includes both request and response headers" {
  create_mock_curl_success

  run "${HEADERS_SCRIPT}" -i https://example.com
  [ "$status" -eq 0 ]

  # Should include response headers
  [[ "$output" == *"HTTP/2 200"* ]]
  [[ "$output" == *"content-type: text/html"* ]]

  # Should ALSO include request headers (lines with >)
  [[ "$output" == *"GET / HTTP/2"* ]]
  [[ "$output" == *"Host: example.com"* ]]
  [[ "$output" == *"User-Agent:"* ]]

  # Should NOT include the response headers label when using -i
  [[ "$output" != *"=== RESPONSE HEADERS ==="* ]]
}

# Test --include flag (long form)
@test "headers --include includes both request and response headers" {
  create_mock_curl_success

  run "${HEADERS_SCRIPT}" --include https://example.com
  [ "$status" -eq 0 ]

  # Should include both request and response headers
  [[ "$output" == *"GET / HTTP/2"* ]]
  [[ "$output" == *"HTTP/2 200"* ]]
}

# Test that curl's metadata lines are filtered out
@test "headers filters out curl metadata lines" {
  create_mock_curl_success

  run "${HEADERS_SCRIPT}" https://example.com
  [ "$status" -eq 0 ]

  # Should NOT include curl metadata (lines starting with *)
  [[ "$output" != *"* Connected to"* ]]
  [[ "$output" != *"* ALPN"* ]]
  [[ "$output" != *"* Connection"* ]]
}

# Test with custom headers
@test "headers passes through custom headers to curl" {
  create_mock_curl_with_custom_headers

  run "${HEADERS_SCRIPT}" -i -H "Content-Type: application/json" -H "Authorization: Bearer token123" https://api.example.com
  [ "$status" -eq 0 ]

  # Should show the custom headers in request
  [[ "$output" == *"Content-Type: application/json"* ]]
  [[ "$output" == *"Authorization: Bearer token123"* ]]
}

# Test with POST request
@test "headers supports custom request methods with -X" {
  create_mock_curl_with_custom_headers

  run "${HEADERS_SCRIPT}" -i -X POST https://api.example.com
  [ "$status" -eq 0 ]

  # Should show POST in request
  [[ "$output" == *"POST"* ]]
}

# Test with request data
@test "headers passes through request data with -d" {
  # Create a mock that checks for -d flag
  cat > "${MOCK_CURL}" <<'EOF'
#!/bin/bash
# Check if -d flag was passed
if [[ "$*" == *"-d"* ]]; then
  cat >&2 <<'CURL_OUTPUT'
> POST /api HTTP/2
> Content-Type: application/x-www-form-urlencoded
< HTTP/2 200
< content-type: application/json
CURL_OUTPUT
  exit 0
else
  echo "Data flag not found" >&2
  exit 1
fi
EOF
  chmod +x "${MOCK_CURL}"

  run "${HEADERS_SCRIPT}" -i -d "key=value" https://api.example.com
  [ "$status" -eq 0 ]
  [[ "$output" == *"POST"* ]]
}

# Test error handling for invalid URL
@test "headers handles curl errors gracefully" {
  create_mock_curl_error

  run "${HEADERS_SCRIPT}" https://invalid-domain-that-does-not-exist.com

  # Should exit with error status
  [ "$status" -ne 0 ]

  # Should show the error message
  [[ "$output" == *"Could not resolve host"* ]]
}

# Test that URL argument is required
@test "headers requires a URL argument" {
  # Create a mock that exits with error if no URL
  cat > "${MOCK_CURL}" <<'EOF'
#!/bin/bash
echo "curl: try 'curl --help' for more information" >&2
exit 2
EOF
  chmod +x "${MOCK_CURL}"

  run "${HEADERS_SCRIPT}"

  # Should fail when no URL is provided
  [ "$status" -ne 0 ]
}

# Test combining multiple curl options
@test "headers correctly combines multiple curl options" {
  create_mock_curl_with_custom_headers

  run "${HEADERS_SCRIPT}" -X POST -H "Content-Type: application/json" -d '{"test":"data"}' https://api.example.com
  [ "$status" -eq 0 ]

  # Should successfully process all options
  [[ "$output" == *"HTTP/2"* ]]
}

# Test that response codes are visible
@test "headers displays HTTP response codes" {
  create_mock_curl_success

  run "${HEADERS_SCRIPT}" https://example.com
  [ "$status" -eq 0 ]

  # Should show the response code
  [[ "$output" == *"200"* ]]
}

# Test with HTTPS URL
@test "headers works with HTTPS URLs" {
  create_mock_curl_success

  run "${HEADERS_SCRIPT}" https://example.com
  [ "$status" -eq 0 ]

  # Should successfully handle HTTPS
  [[ "$output" == *"HTTP"* ]]
}

# Test response header formatting
@test "headers preserves response header formatting" {
  create_mock_curl_success

  run "${HEADERS_SCRIPT}" https://example.com
  [ "$status" -eq 0 ]

  # Headers should have proper key: value format
  [[ "$output" == *"content-type:"* ]]
  [[ "$output" == *"server:"* ]]
  [[ "$output" == *"cache-control:"* ]]
}

# Test that common response headers are shown
@test "headers displays common HTTP response headers" {
  create_mock_curl_success

  run "${HEADERS_SCRIPT}" https://example.com
  [ "$status" -eq 0 ]

  # Should show common headers
  [[ "$output" == *"content-type"* ]]
  [[ "$output" == *"date"* ]]
  [[ "$output" == *"server"* ]]
}

# Test with -i flag and URL with query parameters
@test "headers handles URLs with query parameters" {
  create_mock_curl_success

  run "${HEADERS_SCRIPT}" "https://example.com?param=value&other=123"
  [ "$status" -eq 0 ]

  # Should successfully handle URL with parameters
  [[ "$output" == *"HTTP"* ]]
}

# Test that script doesn't include response body
@test "headers does not include response body" {
  # Even though curl outputs body, headers script should filter it
  cat > "${MOCK_CURL}" <<'EOF'
#!/bin/bash
cat >&2 <<'CURL_OUTPUT'
< HTTP/2 200
< content-type: text/html
<
CURL_OUTPUT
# Response body would go to stdout
echo "<!DOCTYPE html><html>This is body content</html>"
exit 0
EOF
  chmod +x "${MOCK_CURL}"

  run "${HEADERS_SCRIPT}" https://example.com
  [ "$status" -eq 0 ]

  # Should NOT include HTML body content
  [[ "$output" != *"<!DOCTYPE"* ]]
  [[ "$output" != *"<html>"* ]]
}

# Test help text includes all options
@test "headers help includes all documented options" {
  run "${HEADERS_SCRIPT}" --help
  [ "$status" -eq 0 ]

  # Should document all options
  [[ "$output" == *"-X"* ]]
  [[ "$output" == *"--request"* ]]
  [[ "$output" == *"-H"* ]]
  [[ "$output" == *"--header"* ]]
  [[ "$output" == *"-d"* ]]
  [[ "$output" == *"--data"* ]]
  [[ "$output" == *"-i"* ]]
  [[ "$output" == *"--include"* ]]
  [[ "$output" == *"-h"* ]]
  [[ "$output" == *"--help"* ]]
}

# Test help text includes examples
@test "headers help includes usage examples" {
  run "${HEADERS_SCRIPT}" --help
  [ "$status" -eq 0 ]

  # Should include examples
  [[ "$output" == *"EXAMPLES"* ]]
  [[ "$output" == *"headers https://example.com"* ]]
}

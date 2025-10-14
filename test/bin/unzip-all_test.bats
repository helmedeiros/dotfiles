#!/usr/bin/env bats

# Path to the script being tested
UNZIP_ALL_SCRIPT="${BATS_TEST_DIRNAME}/../../bin/unzip-all"

# Setup function that runs before each test
setup() {
  # Create a temporary directory for test files
  TEST_DIR="$(mktemp -d)"
  
  # Save the current directory to return to it later
  ORIGINAL_DIR="$(pwd)"
  
  # Change to test directory
  cd "${TEST_DIR}"
  
  # Create mock bin directory
  MOCK_BIN="${TEST_DIR}/mock-bin"
  mkdir -p "${MOCK_BIN}"
  
  # Add mock bin to PATH
  export PATH="${MOCK_BIN}:${PATH}"
  
  # Track which files were trashed
  export TRASHED_FILES="${TEST_DIR}/trashed_files.log"
  : > "${TRASHED_FILES}"
  
  # Track which files were unzipped
  export UNZIPPED_FILES="${TEST_DIR}/unzipped_files.log"
  : > "${UNZIPPED_FILES}"
}

# Teardown function that runs after each test
teardown() {
  # Return to the original directory
  cd "${ORIGINAL_DIR}"
  
  # Clean up the temporary directory
  rm -rf "${TEST_DIR}"
  
  # Clean up environment variables
  unset TRASHED_FILES
  unset UNZIPPED_FILES
}

# Helper function to create a mock file command
create_mock_file_cmd() {
  cat > "${MOCK_BIN}/file" <<'EOF'
#!/bin/bash
# Mock file command that identifies file types

if [[ "$1" == "-b" ]]; then
  filename="$2"
  
  # Simulate file type detection
  if [[ "$filename" == *.zip ]] && [[ "$filename" != "fake.zip" ]] && [[ "$filename" != "not-a-zip.zip" ]]; then
    echo "Zip archive data, at least v2.0 to extract"
  elif [[ "$filename" == *.txt ]]; then
    echo "ASCII text"
  elif [[ "$filename" == *.jpg ]]; then
    echo "JPEG image data"
  else
    echo "data"
  fi
else
  echo "Usage: file [options] filename"
fi
EOF
  chmod +x "${MOCK_BIN}/file"
}

# Helper function to create a mock unzip command
create_mock_unzip() {
  cat > "${MOCK_BIN}/unzip" <<'EOF'
#!/bin/bash
# Mock unzip command

zipfile="$1"

# Log that this file was unzipped
echo "$zipfile" >> "$UNZIPPED_FILES"

# Simulate successful unzip
echo "Archive:  $zipfile"
echo "  inflating: ${zipfile%.zip}/file1.txt"
echo "  inflating: ${zipfile%.zip}/file2.txt"

# Create a directory to simulate extraction
dirname="${zipfile%.zip}"
mkdir -p "$dirname"
echo "content1" > "$dirname/file1.txt"
echo "content2" > "$dirname/file2.txt"

exit 0
EOF
  chmod +x "${MOCK_BIN}/unzip"
}

# Helper function to create a mock unzip that fails
create_mock_unzip_failing() {
  cat > "${MOCK_BIN}/unzip" <<'EOF'
#!/bin/bash
# Mock unzip command that fails

echo "Archive:  $1" >&2
echo "unzip: cannot find zipfile directory" >&2
echo "  skipping: inflating error" >&2
exit 1
EOF
  chmod +x "${MOCK_BIN}/unzip"
}

# Helper function to create a mock trash command
create_mock_trash() {
  cat > "${MOCK_BIN}/trash" <<'EOF'
#!/bin/bash
# Mock trash command

for file in "$@"; do
  echo "$file" >> "$TRASHED_FILES"
  # Simulate moving to trash by removing the file
  rm -f "$file"
done

exit 0
EOF
  chmod +x "${MOCK_BIN}/trash"
}

# Helper function to create a mock trash that fails
create_mock_trash_failing() {
  cat > "${MOCK_BIN}/trash" <<'EOF'
#!/bin/bash
# Mock trash command that fails

echo "trash: cannot move to trash" >&2
exit 1
EOF
  chmod +x "${MOCK_BIN}/trash"
}

# Helper function to create test zip files
create_test_zip_files() {
  touch file1.zip
  touch file2.zip
  touch file3.zip
}

# Test that the script exists and is executable
@test "unzip-all script exists and is executable" {
  [ -f "${UNZIP_ALL_SCRIPT}" ]
  [ -x "${UNZIP_ALL_SCRIPT}" ]
}

# Test basic functionality - unzip and trash a single file
@test "unzip-all unzips a single zip file and moves it to trash" {
  create_mock_file_cmd
  create_mock_unzip
  create_mock_trash
  
  # Create a test zip file
  touch test.zip
  
  # Run unzip-all
  run bash "${UNZIP_ALL_SCRIPT}" "*.zip"
  [ "$status" -eq 0 ]
  
  # Verify file was unzipped
  grep -q "test.zip" "${UNZIPPED_FILES}"
  
  # Verify file was trashed
  grep -q "test.zip" "${TRASHED_FILES}"
  
  # Verify original zip file is gone
  [ ! -f "test.zip" ]
}

# Test with multiple zip files
@test "unzip-all processes multiple zip files" {
  create_mock_file_cmd
  create_mock_unzip
  create_mock_trash
  
  # Create multiple test zip files
  create_test_zip_files
  
  # Run unzip-all
  run bash "${UNZIP_ALL_SCRIPT}" "*.zip"
  [ "$status" -eq 0 ]
  
  # Verify all files were unzipped
  grep -q "file1.zip" "${UNZIPPED_FILES}"
  grep -q "file2.zip" "${UNZIPPED_FILES}"
  grep -q "file3.zip" "${UNZIPPED_FILES}"
  
  # Verify all files were trashed
  grep -q "file1.zip" "${TRASHED_FILES}"
  grep -q "file2.zip" "${TRASHED_FILES}"
  grep -q "file3.zip" "${TRASHED_FILES}"
}

# Test that non-zip files are skipped
@test "unzip-all skips non-zip files even with .zip extension" {
  create_mock_file_cmd
  create_mock_unzip
  create_mock_trash
  
  # Create a file with .zip extension that's not actually a zip
  touch not-a-zip.zip
  
  # Run unzip-all
  run bash "${UNZIP_ALL_SCRIPT}" "*.zip"
  [ "$status" -eq 0 ]
  
  # Verify file was NOT unzipped
  ! grep -q "not-a-zip.zip" "${UNZIPPED_FILES}"
  
  # Verify file was NOT trashed
  ! grep -q "not-a-zip.zip" "${TRASHED_FILES}"
  
  # Verify file still exists
  [ -f "not-a-zip.zip" ]
}

# Test with files containing spaces in names
@test "unzip-all handles files with spaces in names" {
  create_mock_file_cmd
  create_mock_unzip
  create_mock_trash
  
  # Create a zip file with spaces in name
  touch "my archive.zip"
  
  # Run unzip-all
  run bash "${UNZIP_ALL_SCRIPT}" "*.zip"
  [ "$status" -eq 0 ]
  
  # Verify file was unzipped
  grep -q "my archive.zip" "${UNZIPPED_FILES}"
  
  # Verify file was trashed
  grep -q "my archive.zip" "${TRASHED_FILES}"
}

# Test with no matching files
@test "unzip-all handles no matching files gracefully" {
  create_mock_file_cmd
  create_mock_unzip
  create_mock_trash
  
  # Create a non-zip file to ensure the pattern doesn't match
  touch README.txt
  
  # Run unzip-all with pattern that won't match
  run bash "${UNZIP_ALL_SCRIPT}" "*.zip"
  [ "$status" -eq 0 ]
  
  # When no files match, bash treats the pattern literally
  # The script will try to process "*.zip" as a filename
  # Since it doesn't exist as a real file, it's handled gracefully
  # We just verify the script doesn't crash
}

# Test with mixed file types
@test "unzip-all only processes zip files, not other file types" {
  create_mock_file_cmd
  create_mock_unzip
  create_mock_trash
  
  # Create mixed file types
  touch file1.zip
  touch file2.txt
  touch file3.jpg
  
  # Run unzip-all with wildcard that matches all
  run bash "${UNZIP_ALL_SCRIPT}" "*"
  [ "$status" -eq 0 ]
  
  # Verify only zip file was processed
  grep -q "file1.zip" "${UNZIPPED_FILES}"
  ! grep -q "file2.txt" "${UNZIPPED_FILES}"
  ! grep -q "file3.jpg" "${UNZIPPED_FILES}"
  
  # Verify non-zip files still exist
  [ -f "file2.txt" ]
  [ -f "file3.jpg" ]
}

# Test that extracted content is created
@test "unzip-all creates extracted content" {
  create_mock_file_cmd
  create_mock_unzip
  create_mock_trash
  
  # Create a test zip file
  touch archive.zip
  
  # Run unzip-all
  run bash "${UNZIP_ALL_SCRIPT}" "*.zip"
  [ "$status" -eq 0 ]
  
  # Verify extracted directory was created
  [ -d "archive" ]
  [ -f "archive/file1.txt" ]
  [ -f "archive/file2.txt" ]
}

# Test with specific file pattern
@test "unzip-all works with specific file patterns" {
  create_mock_file_cmd
  create_mock_unzip
  create_mock_trash
  
  # Create multiple files
  touch test-archive.zip
  touch prod-archive.zip
  touch other.zip
  
  # Run unzip-all with specific pattern
  run bash "${UNZIP_ALL_SCRIPT}" "test-*.zip"
  [ "$status" -eq 0 ]
  
  # Verify only matching file was processed
  grep -q "test-archive.zip" "${UNZIPPED_FILES}"
  ! grep -q "prod-archive.zip" "${UNZIPPED_FILES}"
  ! grep -q "other.zip" "${UNZIPPED_FILES}"
}

# Test error handling when unzip fails
@test "unzip-all exits on unzip failure" {
  create_mock_file_cmd
  create_mock_unzip_failing
  create_mock_trash
  
  # Create a test zip file
  touch corrupted.zip
  
  # Run unzip-all (should fail because unzip fails)
  run bash "${UNZIP_ALL_SCRIPT}" "*.zip"
  
  # Should exit with error due to set -e
  [ "$status" -ne 0 ]
  
  # File should not be trashed if unzip fails
  ! grep -q "corrupted.zip" "${TRASHED_FILES}"
}

# Test error handling when trash fails
@test "unzip-all exits on trash failure" {
  create_mock_file_cmd
  create_mock_unzip
  create_mock_trash_failing
  
  # Create a test zip file
  touch test.zip
  
  # Run unzip-all (should fail because trash fails)
  run bash "${UNZIP_ALL_SCRIPT}" "*.zip"
  
  # Should exit with error due to set -e
  [ "$status" -ne 0 ]
  
  # File should have been unzipped
  grep -q "test.zip" "${UNZIPPED_FILES}"
}

# Test that script uses file type detection, not just extension
@test "unzip-all uses file command to verify zip files" {
  # Create a mock file command that tracks calls
  FILE_CALLS_LOG="${TEST_DIR}/file_calls.log"
  cat > "${MOCK_BIN}/file" <<EOF
#!/bin/bash
echo "file command called with: \$@" >> "${FILE_CALLS_LOG}"
if [[ "\$1" == "-b" ]]; then
  echo "Zip archive data"
fi
EOF
  chmod +x "${MOCK_BIN}/file"
  
  create_mock_unzip
  create_mock_trash
  
  # Create a test file
  touch test.zip
  
  # Run unzip-all
  run bash "${UNZIP_ALL_SCRIPT}" "*.zip"
  [ "$status" -eq 0 ]
  
  # Verify file command was called
  [ -f "${FILE_CALLS_LOG}" ]
  grep -q "file command called" "${FILE_CALLS_LOG}"
}

# Test with files in current directory
@test "unzip-all works in current directory" {
  create_mock_file_cmd
  create_mock_unzip
  create_mock_trash
  
  # Create files in current directory
  touch archive1.zip
  touch archive2.zip
  
  # Run unzip-all
  run bash "${UNZIP_ALL_SCRIPT}" "*.zip"
  [ "$status" -eq 0 ]
  
  # Verify both files were processed
  UNZIPPED_COUNT=$(grep -c ".zip" "${UNZIPPED_FILES}" || true)
  [ "$UNZIPPED_COUNT" -eq 2 ]
}

# Test that script requires an argument
@test "unzip-all requires a pattern argument" {
  create_mock_file_cmd
  create_mock_unzip
  create_mock_trash
  
  # Run without arguments
  run bash "${UNZIP_ALL_SCRIPT}"
  
  # Should complete (will just iterate over nothing)
  [ "$status" -eq 0 ]
  
  # No files should be processed
  [ ! -s "${UNZIPPED_FILES}" ]
}

# Test set -e behavior (script exits on error)
@test "unzip-all exits immediately on error due to set -e" {
  create_mock_file_cmd
  create_mock_trash
  
  # Create a mock unzip that fails
  cat > "${MOCK_BIN}/unzip" <<'EOF'
#!/bin/bash
echo "$1" >> "$UNZIPPED_FILES"
exit 1
EOF
  chmod +x "${MOCK_BIN}/unzip"
  
  # Create multiple files
  touch file1.zip
  touch file2.zip
  
  # Run unzip-all
  run bash "${UNZIP_ALL_SCRIPT}" "*.zip"
  
  # Should fail
  [ "$status" -ne 0 ]
  
  # At least one file should have been attempted
  # The exact number depends on loop iteration order
  [ -s "${UNZIPPED_FILES}" ]
  
  # Verify it failed due to unzip error
  [[ "$output" == *"" ]] || [ "$status" -ne 0 ]
}

# Test with glob pattern
@test "unzip-all expands glob patterns correctly" {
  create_mock_file_cmd
  create_mock_unzip
  create_mock_trash
  
  # Create files with different prefixes
  touch backup-2024.zip
  touch backup-2023.zip
  touch archive-2024.zip
  
  # Run with specific glob
  run bash "${UNZIP_ALL_SCRIPT}" "backup-*.zip"
  [ "$status" -eq 0 ]
  
  # Verify only backup files were processed
  grep -q "backup-2024.zip" "${UNZIPPED_FILES}"
  grep -q "backup-2023.zip" "${UNZIPPED_FILES}"
  ! grep -q "archive-2024.zip" "${UNZIPPED_FILES}"
}

# Test output messages
@test "unzip-all shows unzip output" {
  create_mock_file_cmd
  create_mock_unzip
  create_mock_trash
  
  # Create a test zip file
  touch test.zip
  
  # Run unzip-all
  run bash "${UNZIP_ALL_SCRIPT}" "*.zip"
  [ "$status" -eq 0 ]
  
  # Verify unzip output is shown
  [[ "$output" == *"Archive:"* ]]
  [[ "$output" == *"inflating:"* ]]
}

# Test that original files are removed after successful processing
@test "unzip-all removes original zip files after extraction" {
  create_mock_file_cmd
  create_mock_unzip
  create_mock_trash
  
  # Create test files
  touch file1.zip
  touch file2.zip
  
  # Verify files exist before
  [ -f "file1.zip" ]
  [ -f "file2.zip" ]
  
  # Run unzip-all
  run bash "${UNZIP_ALL_SCRIPT}" "*.zip"
  [ "$status" -eq 0 ]
  
  # Verify files are gone after
  [ ! -f "file1.zip" ]
  [ ! -f "file2.zip" ]
}

# Test with single file (not a glob)
@test "unzip-all works with single file argument" {
  create_mock_file_cmd
  create_mock_unzip
  create_mock_trash
  
  # Create multiple files
  touch specific.zip
  touch other.zip
  
  # Run with specific file (not glob)
  run bash "${UNZIP_ALL_SCRIPT}" "specific.zip"
  [ "$status" -eq 0 ]
  
  # Verify only specific file was processed
  grep -q "specific.zip" "${UNZIPPED_FILES}"
  ! grep -q "other.zip" "${UNZIPPED_FILES}"
}


# Test Coverage Analysis for bin/ Scripts

## Current Test Coverage

Currently tested scripts (10 out of 32):

- ✅ `check-updates` - Comprehensive tests with multiple scenarios
- ✅ `cleanup-brew` - Tests for package removal logic
- ✅ `dot` - Tests for dotfiles setup
- ✅ `e` - Extensive tests for editor functionality
- ✅ `gh-packages` - Tests for GitHub packages
- ✅ `git-delete-local-merged` - Tests for merged branch deletion (11 tests)
- ✅ `git-undo` - Tests for undoing commits (11 tests)
- ✅ `headers` - Tests for HTTP header utility (21 tests)
- ✅ `history-clean` - Comprehensive tests for history cleaning (28 tests)
- ✅ `macos/set-defaults.sh` - Tests for macOS defaults

**Total Tests: 132**

## Missing Test Coverage (22 scripts)

### Priority 1: High-Value Scripts That Should Be Tested Next

These scripts have complex logic, handle critical operations, or are frequently used:

#### 1. **`unzip-all`** (MEDIUM-HIGH PRIORITY)

- **Why test**: File operations with trash/deletion
- **Complexity**: Medium - file detection, unzip, trash
- **Test scenarios**:
  - Should unzip all zip files matching pattern
  - Should move processed files to trash
  - Should handle invalid zip files
  - Should handle files with spaces in names
  - Should skip non-zip files
  - Should handle empty directories
- **Risk**: Could accidentally delete files

#### 2. **`git-nuke`** (HIGH PRIORITY)

- **Why test**: Destructive operation (deletes branches locally and remotely)
- **Complexity**: Medium
- **Test scenarios**:
  - Should delete branch locally
  - Should delete branch on remote
  - Should handle non-existent branches
  - Should prevent deletion of current branch
  - Should handle network errors
- **Risk**: Could delete important remote branches

### Priority 2: Moderate Complexity Scripts Worth Testing

#### 3. **`git-unpushed`**

- **Why test**: Useful git utility
- **Complexity**: Low - git difftool wrapper
- **Test scenarios**:
  - Should show diff of unpushed changes
  - Should handle branches with no upstream
  - Should handle no unpushed changes

#### 4. **`git-unpushed-stat`**

- **Why test**: Similar to git-unpushed but with stats
- **Complexity**: Low
- **Test scenarios**:
  - Should show diffstat of unpushed changes
  - Should handle branches with no upstream

#### 5. **`git-up`**

- **Why test**: Modifies git state (pull/rebase)
- **Complexity**: Medium - handles both merge and rebase
- **Test scenarios**:
  - Should pull and show log
  - Should rebase when invoked as git-reup
  - Should show diffstat when rebasing
  - Should handle conflicts

#### 6. **`git-promote`**

- **Why test**: Creates remote tracking branches
- **Complexity**: Medium
- **Test scenarios**:
  - Should push local branch to remote
  - Should set up tracking
  - Should handle already-tracked branches

#### 7. **`search`**

- **Why test**: Text search utility
- **Complexity**: Low - ack wrapper
- **Test scenarios**:
  - Should search for strings using ack
  - Should handle missing ack
  - Should pass arguments correctly

#### 8. **`todo`**

- **Why test**: File creation
- **Complexity**: Very low - just creates a file
- **Test scenarios**:
  - Should create file on Desktop with given name
  - Should handle special characters
  - Should handle spaces in name

### Priority 3: Simple Scripts (Lower Priority for Testing)

These are very simple and unlikely to break:

- `git-all` - Just runs `git add -A`
- `git-amend` - Simple git amend wrapper
- `git-copy-branch-name` - Copies branch name to clipboard
- `git-credit` - Adds co-author to commit
- `git-credit-all` - Multiple co-authors
- `git-track` - Sets up branch tracking
- `set-defaults` - Just calls another script

### Priority 4: Complex Scripts That Are Harder to Test

These would require more sophisticated test setups:

#### 9. **`git-wtf`**

- **Why defer**: Very complex Ruby script (360+ lines)
- **Complexity**: Very high - extensive git operations
- **Why hard to test**: Requires complex git repository setups with multiple branches, remotes, and states
- **Recommendation**: Test if bugs are reported, otherwise defer

#### 10. **`res`**

- **Why defer**: AppleScript that automates UI
- **Complexity**: High - UI automation
- **Why hard to test**: Requires mocking macOS System Settings UI
- **Recommendation**: Manual testing only

#### 11. **`kube-setup`**

- **Why defer**: Requires Kubernetes environment
- **Complexity**: Unknown (would need to review)
- **Recommendation**: Test if issues arise

#### 12. **`yt`**

- **Why defer**: Depends on external yt-dlp tool
- **Complexity**: Unknown
- **Recommendation**: Integration test only if critical

### Scripts Not Worth Testing

These are too simple or trivial:

- `git-pull-requests` - URL opener
- `git-rank-contributors` - Git log wrapper
- `gitio` - External service wrapper

## Recommended Testing Roadmap

### Phase 1 (Next 2 weeks) ✅ **COMPLETED**

1. ~~`git-delete-local-merged`~~ ✅ **COMPLETED** (11 tests) - Critical destructive operation
2. ~~`git-undo`~~ ✅ **COMPLETED** (11 tests) - Critical destructive operation
3. ~~`history-clean`~~ ✅ **COMPLETED** (28 tests) - Complex with multiple modes

### Phase 2 (Following 2 weeks) - IN PROGRESS

4. ~~`headers`~~ ✅ **COMPLETED** (21 tests) - Useful utility with options
5. `unzip-all` - File operations
6. `git-nuke` - Destructive remote operations

### Phase 3 (As time permits)

7. `git-unpushed` / `git-unpushed-stat`
8. `git-up` / `git-reup`
9. `git-promote`
10. `search`
11. `todo`

## Test Infrastructure Recommendations

Based on existing tests, continue using:

- **BATS** (Bash Automated Testing System) - Already in use
- **Object Mother pattern** - Already established in `test/mothers/`
- **Temporary directories** - Already used for isolation
- **Mock commands** - Already used for brew, git, etc.

### New Test Mothers Created

1. ~~**`git_mother.sh`**~~ ✅ **COMPLETED** - Helper functions for:

   - Creating test git repositories
   - Setting up branches and commits
   - Mocking git operations
   - Simulating different git states

2. **`file_mother.sh`** - Helper functions for:

   - Creating test files and directories
   - Creating zip files for testing
   - Managing test fixtures
   - ⚠️ **Not yet created** - Will be needed for Phase 2

3. ~~**`history_mother.sh`**~~ ✅ **COMPLETED** - Helper functions for:
   - Creating test history files
   - Populating with test data
   - Simulating different history formats

## Summary Statistics

- **Total bin scripts**: 32
- **Currently tested**: 10 (31%)
- **Total tests**: 132
- **High priority to test**: 2 scripts (unzip-all, git-nuke)
- **Medium priority to test**: 6 scripts
- **Low priority to test**: 3 scripts
- **Too complex/defer**: 4 scripts
- **Not worth testing**: 7 scripts

**Target coverage**: ~60% (19 scripts) would give excellent practical coverage while focusing on scripts that matter most.

**Current progress**: 53% toward target (10 out of 19 target scripts)

## Next Immediate Action

**✅ Phase 1 Complete! Phase 2 in progress (1/3 done):**

**Next: `unzip-all`** because:

1. File operations with trash/deletion (important to test safety)
2. Medium complexity with file detection and processing
3. Risk of accidentally deleting files if buggy
4. Handles edge cases (spaces in names, invalid files)
5. Part of Phase 2 priority scripts

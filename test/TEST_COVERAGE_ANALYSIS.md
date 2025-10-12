# Test Coverage Analysis for bin/ Scripts

## Current Test Coverage

Currently tested scripts (6 out of 32):

- ✅ `check-updates` - Comprehensive tests with multiple scenarios
- ✅ `cleanup-brew` - Tests for package removal logic
- ✅ `dot` - Tests for dotfiles setup
- ✅ `e` - Extensive tests for editor functionality
- ✅ `gh-packages` - Tests for GitHub packages
- ✅ `macos/set-defaults.sh` - Tests for macOS defaults

## Missing Test Coverage (26 scripts)

### Priority 1: High-Value Scripts That Should Be Tested Next

These scripts have complex logic, handle critical operations, or are frequently used:

#### 1. **`git-delete-local-merged`** (HIGH PRIORITY)

- **Why test**: Destructive operation (deletes branches)
- **Complexity**: Moderate - uses git commands and filters
- **Test scenarios**:
  - Should identify merged branches correctly
  - Should not delete current branch
  - Should not delete master/main branch
  - Should handle no merged branches case
  - Should handle branches with special characters in names
- **Risk**: Could accidentally delete important branches

#### 2. **`git-undo`** (HIGH PRIORITY)

- **Why test**: Destructive operation (modifies git history)
- **Complexity**: Low - simple reset command
- **Test scenarios**:
  - Should undo last commit but keep changes staged
  - Should work when there's only one commit
  - Should handle detached HEAD state
  - Should preserve working directory changes
- **Risk**: Could lose uncommitted work if misused

#### 3. **`history-clean`** (HIGH PRIORITY)

- **Why test**: Modifies important user data (shell history)
- **Complexity**: High - multiple modes, backup creation, pattern matching
- **Test scenarios**:
  - Should remove specific line numbers
  - Should remove lines matching pattern (-p flag)
  - Should remove last N lines (--last flag)
  - Should create backups before modifying
  - Should handle invalid line numbers
  - Should clean autocompletion history
  - Should handle edge cases (empty history, invalid patterns)
- **Risk**: Could lose important history if buggy

#### 4. **`headers`** (MEDIUM-HIGH PRIORITY)

- **Why test**: Has options/flags, makes network requests
- **Complexity**: Medium - argument parsing, curl wrapper
- **Test scenarios**:
  - Should display help with -h/--help
  - Should show only response headers by default
  - Should include request headers with -i flag
  - Should pass through curl arguments correctly
  - Should handle invalid URLs
  - Should handle network errors
- **Value**: Frequently used for debugging

#### 5. **`unzip-all`** (MEDIUM-HIGH PRIORITY)

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

#### 6. **`git-nuke`** (HIGH PRIORITY)

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

#### 7. **`git-unpushed`**

- **Why test**: Useful git utility
- **Complexity**: Low - git difftool wrapper
- **Test scenarios**:
  - Should show diff of unpushed changes
  - Should handle branches with no upstream
  - Should handle no unpushed changes

#### 8. **`git-unpushed-stat`**

- **Why test**: Similar to git-unpushed but with stats
- **Complexity**: Low
- **Test scenarios**:
  - Should show diffstat of unpushed changes
  - Should handle branches with no upstream

#### 9. **`git-up`**

- **Why test**: Modifies git state (pull/rebase)
- **Complexity**: Medium - handles both merge and rebase
- **Test scenarios**:
  - Should pull and show log
  - Should rebase when invoked as git-reup
  - Should show diffstat when rebasing
  - Should handle conflicts

#### 10. **`git-promote`**

- **Why test**: Creates remote tracking branches
- **Complexity**: Medium
- **Test scenarios**:
  - Should push local branch to remote
  - Should set up tracking
  - Should handle already-tracked branches

#### 11. **`search`**

- **Why test**: Text search utility
- **Complexity**: Low - ack wrapper
- **Test scenarios**:
  - Should search for strings using ack
  - Should handle missing ack
  - Should pass arguments correctly

#### 12. **`todo`**

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

#### 13. **`git-wtf`**

- **Why defer**: Very complex Ruby script (360+ lines)
- **Complexity**: Very high - extensive git operations
- **Why hard to test**: Requires complex git repository setups with multiple branches, remotes, and states
- **Recommendation**: Test if bugs are reported, otherwise defer

#### 14. **`res`**

- **Why defer**: AppleScript that automates UI
- **Complexity**: High - UI automation
- **Why hard to test**: Requires mocking macOS System Settings UI
- **Recommendation**: Manual testing only

#### 15. **`kube-setup`**

- **Why defer**: Requires Kubernetes environment
- **Complexity**: Unknown (would need to review)
- **Recommendation**: Test if issues arise

#### 16. **`yt`**

- **Why defer**: Depends on external yt-dlp tool
- **Complexity**: Unknown
- **Recommendation**: Integration test only if critical

### Scripts Not Worth Testing

These are too simple or trivial:

- `git-pull-requests` - URL opener
- `git-rank-contributors` - Git log wrapper
- `gitio` - External service wrapper

## Recommended Testing Roadmap

### Phase 1 (Next 2 weeks)

1. `git-delete-local-merged` - Critical destructive operation
2. `git-undo` - Critical destructive operation
3. `history-clean` - Complex with multiple modes

### Phase 2 (Following 2 weeks)

4. `headers` - Useful utility with options
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

### New Test Mothers to Create

1. **`git_mother.sh`** - Helper functions for:

   - Creating test git repositories
   - Setting up branches and commits
   - Mocking git operations
   - Simulating different git states

2. **`file_mother.sh`** - Helper functions for:

   - Creating test files and directories
   - Creating zip files for testing
   - Managing test fixtures

3. **`history_mother.sh`** - Helper functions for:
   - Creating test history files
   - Populating with test data
   - Simulating different history formats

## Summary Statistics

- **Total bin scripts**: 32
- **Currently tested**: 6 (19%)
- **High priority to test**: 6 scripts
- **Medium priority to test**: 6 scripts
- **Low priority to test**: 3 scripts
- **Too complex/defer**: 4 scripts
- **Not worth testing**: 7 scripts

**Target coverage**: ~60% (19 scripts) would give excellent practical coverage while focusing on scripts that matter most.

## Next Immediate Action

**Start with `git-delete-local-merged`** because:

1. It's a destructive operation (deletes branches)
2. It's moderately complex with filtering logic
3. It's commonly used in development workflows
4. The test will establish patterns for other git utility tests
5. There's real risk of data loss if it has bugs

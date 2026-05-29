# p4merge

[Perforce P4Merge](https://www.perforce.com/products/helix-core-apps/merge-diff-tool-p4merge) as the git diff/merge tool.

## What `install.sh` does

Writes `git config --global` entries to register `p4mergetool` as both `merge.tool` and `diff.tool`, pointing at `/Applications/p4merge.app/Contents/Resources/launchp4merge`.

Expects `p4merge.app` to already be installed in `/Applications/` — it's not in the Brewfile, so install it manually if needed.

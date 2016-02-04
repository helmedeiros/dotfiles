##Setup p4merge as a visual mergetool

git config --global merge.tool p4mergetool
git config --global mergetool.p4mergetool.cmd "/Applications/p4merge.app/Contents/Resources/launchp4merge \$PWD/\$BASE \$PWD/\$REMOTE \$PWD/\$LOCAL \$PWD/\$MERGED"

git config --global mergetool.p4mergetool.trustExitCode false
git config --global mergetool.keepBackup false

##Setup p4merge as a visual diff tool
git config --global diff.tool p4mergetool
git config --global difftool.p4mergetool.cmd "/Applications/p4merge.app/Contents/Resources/launchp4merge \$LOCAL \$REMOTE"

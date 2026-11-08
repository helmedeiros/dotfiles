# shellcheck shell=bash
DEMO_REPO="$PWD"
DEMO_HOME=/tmp/dotfiles-demo
rm -rf "$DEMO_HOME"
mkdir -p "$DEMO_HOME"
export HOME="$DEMO_HOME"
export PATH="$DEMO_HOME/shims:$DEMO_HOME/.dotfiles/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PS1='$ '
export GIT_CONFIG_NOSYSTEM=1
unset CHECK_UPDATES_ASSUME_TTY

mkdir -p "$DEMO_HOME/shims"

cat > "$DEMO_HOME/shims/brew" <<'SH'
#!/bin/bash
case "$1" in
  update) echo "Already up-to-date." ;;
  outdated) printf 'gh\nneovim\nripgrep\n' ;;
  upgrade)
    echo "==> Upgrading 3 outdated packages:"
    echo "gh 2.62.0 -> 2.63.1"
    echo "neovim 0.10.2 -> 0.10.3"
    echo "ripgrep 14.1.0 -> 14.1.1"
    ;;
  bundle) echo "\`brew bundle\` complete! 142 Brewfile dependencies now installed." ;;
esac
SH

cat > "$DEMO_HOME/shims/mas" <<'SH'
#!/bin/bash
echo "Everything is up-to-date"
SH

cat > "$DEMO_HOME/shims/node" <<'SH'
#!/bin/bash
echo "v24.19.0"
SH

cat > "$DEMO_HOME/shims/npm" <<'SH'
#!/bin/bash
case "$1" in
  list) echo '{"dependencies":{"npm":{"version":"11.6.0"},"typescript":{"version":"5.9.2"},"prettier":{"version":"3.6.2"}}}' ;;
  view)
    case "$2" in
      typescript) echo "5.9.3" ;;
      prettier) echo "3.6.2" ;;
    esac
    ;;
esac
SH

for jq_path in /opt/homebrew/bin/jq /usr/local/bin/jq /usr/bin/jq; do
  [ -x "$jq_path" ] && ln -sf "$jq_path" "$DEMO_HOME/shims/jq" && break
done

DOT="$DEMO_HOME/.dotfiles"
mkdir -p "$DOT"/{bin,lib,macos,homebrew,node,script}
cp "$DEMO_REPO/bin/dot" "$DEMO_REPO/bin/check-updates" "$DOT/bin/"
cp "$DEMO_REPO/lib/status.sh" "$DOT/lib/"
cp "$DEMO_REPO/node/.nvmrc" "$DOT/node/"
printf "tap 'helmedeiros/tap'\nbrew 'gh'\nbrew 'neovim'\nbrew 'ripgrep'\n" > "$DOT/Brewfile"

printf '#!/bin/bash\n' > "$DOT/macos/set-defaults.sh"
printf '#!/bin/bash\n' > "$DOT/homebrew/install.sh"
cat > "$DOT/node/update.sh" <<'SH'
#!/bin/bash
echo "Node.js version: v24.19.0"
echo "› Installing latest versions of outdated global npm packages"
echo "  ✅ Successfully updated typescript"
SH
cat > "$DOT/script/install" <<'SH'
#!/bin/bash
echo "Running 31 post-install scripts..."
echo "Post-install scripts completed."
SH
chmod +x "$DEMO_HOME"/shims/* "$DOT"/*/*

git config --global user.name demo
git config --global user.email demo@example.com
git config --global init.defaultBranch master
git config --global merge.stat false
git config --global advice.detachedHead false

git -C "$DOT" init -q
git -C "$DOT" add -A
git -C "$DOT" commit -qm "chore: initial dotfiles"
git clone -q --bare "$DOT" "$DEMO_HOME/origin.git"
git -C "$DOT" remote add origin "$DEMO_HOME/origin.git"
git -C "$DOT" fetch -q origin
git -C "$DOT" branch -q --set-upstream-to=origin/master master

DEMO_UPSTREAM="$DEMO_HOME/upstream"
git clone -q "$DEMO_HOME/origin.git" "$DEMO_UPSTREAM"
for subject in "feat(ghostty): add a split-pane keybinding" "fix(zsh): stop zoxide shadowing cd in scripts" "chore(brewfile): track the ripgrep formula"; do
  git -C "$DEMO_UPSTREAM" commit -q --allow-empty -m "$subject"
done
git -C "$DEMO_UPSTREAM" push -q origin master

cd "$DEMO_HOME" || return

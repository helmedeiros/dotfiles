# Git identity template

Copy `identity.sh.example` into your `~/.dot-secrets/git/` directory and rename it to `identity.sh`:

```sh
cp identity.sh.example ~/.dot-secrets/git/identity.sh
$EDITOR ~/.dot-secrets/git/identity.sh
```

When `script/bootstrap` runs `setup_gitconfig`, it sources `~/.dot-secrets/git/identity.sh` first and only prompts you interactively if either `GIT_AUTHOR_NAME` or `GIT_AUTHOR_EMAIL` is empty (or the file is missing).

For public repositories, prefer the GitHub `users.noreply.github.com` alias so your real email never appears in commit metadata. Look up your numeric user id at `https://api.github.com/users/<your-username>` and construct the address as `<id>+<username>@users.noreply.github.com`.

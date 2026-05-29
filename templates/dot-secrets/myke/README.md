# myke configuration template

[myke](https://github.com/omio-labs/myke) is a Make-like task runner published as a single binary outside Homebrew. The URL of the release you want is per-employer / per-team, so it lives in `.dot-secrets` rather than the public dotfiles repo.

Copy `config.sh.example` into your `~/.dot-secrets/myke/` directory and rename it:

```sh
mkdir -p ~/.dot-secrets/myke
cp config.sh.example ~/.dot-secrets/myke/config.sh
$EDITOR ~/.dot-secrets/myke/config.sh
```

Set `MYKE_RELEASE_URL` to the full URL of the binary you want installed at `~/.myke/myke`. If the file is missing or `MYKE_RELEASE_URL` is empty, `myke/install.sh` is a no-op — useful when you don't use myke at the moment.

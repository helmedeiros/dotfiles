# Transmission

[Transmission](https://transmissionbt.com) torrent client. Installed via the Brewfile cask.

## What `install.sh` does

Writes three `defaults` keys that enable the blocklist (`BlocklistURL`, `BlocklistAutoUpdate`, `BlocklistNew`) so Transmission auto-fetches and keeps fresh the bitsurge biglist.p2p blocklist.

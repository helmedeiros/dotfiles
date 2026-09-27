# Transmission

[Transmission](https://transmissionbt.com) torrent client. Installed via the Brewfile cask.

There is no `install.sh`. It used to write three `defaults` keys —
`BlocklistURL`, `BlocklistAutoUpdate` and `BlocklistNew` — pointing Transmission
at `http://john.bitsurge.net/public/biglist.p2p.gz` and telling it to refresh
that list automatically.

That was removed because the host stopped answering, so the blocklist had
silently been fetching nothing, while an abandoned domain plus plaintext HTTP
plus auto-update is a standing invitation: whoever registers the domain next
gets to serve a blocklist that Transmission applies without asking.

To re-enable it, pick a mirror you trust, confirm it actually serves the list
over HTTPS, and set it in Transmission's own preferences (Peers › Blocklist)
rather than here — a blocklist URL is a personal preference, not machine setup.

# Robo 3T

[Robo 3T](https://robomongo.org) (formerly Robomongo) — MongoDB client. Brewfile entry is currently commented out (the app was merged into MongoDB Compass), so install manually if you still need it.

## What `install.sh` does

Restores Robo 3T's connection list from `~/.dot-secrets/robo3t/` into `~/.3T/robo-3t/<latest-version>/`. Errors out if Robo 3T isn't installed or has never been launched (the target directory only exists after first run).

## Files

- `uuidhelpers.js` — script available inside Robo 3T's editor for UUID conversions.

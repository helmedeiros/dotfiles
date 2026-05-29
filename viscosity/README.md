# Viscosity

[Viscosity](https://www.sparklabs.com/viscosity/) OpenVPN client. Installed via the Brewfile cask.

## What `install.sh` does

Configures network-leak prevention by:

- Enabling `AllowOpenVPNScripts` via `Viscosity -setSecureGlobalSetting` (best-effort; may need to be set manually in Viscosity preferences if the binary isn't reachable yet).
- Installing `disablenetwork.py` into `/Library/Application Support/ViscosityScripts/` with root ownership, which Viscosity invokes when a VPN connection drops.

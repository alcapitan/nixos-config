# ❄️ My NixOS configs

This repository contains my declarative NixOS configurations for:
- 💻 **Laptop:** Dell Latitude 3510
- 🌐 **VPS:** Remote server (currently building in a `nix-build` environment)
- 🖥️ **Desktop:** Planned

## 🛠️ Custom Workflow Commands

I use custom aliases/scripts to manage system updates cleanly:

| Command | Action |
| :---: | :--- |
| `nix-switch` | Build & apply changes, set as new default boot generation (nixos-rebuild switch). |
| `nix-test` | Apply changes to the running system without modifying the bootloader profile. Reverts on reboot. |
| `nix-dry` | Dry-run build to check for errors without altering the system. |
| `nix-boot` | Build & register changes for the next reboot without applying them now (nixos-rebuild boot). |
| `nix-update` | Update flake.lock inputs and rebuild the system. |
| `nix-audit` | Scan installed packages for known vulnerabilities / CVEs. |

## 🔒 Secrets & Exclusions

Necessary information needed for the system to work must be located at: 
```
/var/lib/secrets/
~/.borg-exclude
```

## 🗂️ Repository Structure

```text
├── flake.nix             # Flake entry point (hosts & inputs definition)
├── flake.lock            # Pinned dependencies
├── common/               # Shared system configurations & users setup
├── home/                 # Home Manager profiles (user dotfiles, desktop comfort, user commands and tools)
├── modules/              # Custom modular NixOS features (dns, desktop environment, thematic workflows...)
└── hosts/                # Device specific configurations
```
# 󰑃 Jacob's NixOS Golden Build (2026)
Modular NixOS configuration for an AMD Ryzen 7 7800X3D and NVIDIA RTX 5070 (Blackwell).

## 🚀 Key Features
- **NixOS 25.11 (Xantusia)**: Tracking the stable release branch for production reliability.
- **Blackwell Optimized**: Dedicated `nvidia.nix` using open-kernel modules and Linux 6.18-zen.
- **Smart Hardware Toggle**: Flake-based switchboard allows building for **Physical Metal** or **Hyper-V VM** from one source.
- **Creative Suite**: Pre-configured **DaVinci Resolve Studio** and **OBS** with custom `drs-fix` for Linux audio.

## 🛠 Quick Commands
- `sudo nixos-rebuild switch --flake .#nixos`: Update the main gaming/editing rig.
- `sudo nixos-rebuild switch --flake .#vm`: Spin up a lightweight test environment.
- `showcase`: System overview with Fastfetch and config tree.
- `cleanup`: Delete system generations older than 7 days.

## 📂 Configuration Structure
- `flake.nix`: The "Switchboard" defining host profiles.
- `configuration.nix`: The Universal Core (Users, DE, System settings).
- `nvidia.nix`: The Muscle (RTX 5070 Blackwell drivers).
- `creative.nix`: The Workshop (Resolve Studio & Shell scripts).
- `system-apps.nix`: The Toolbox (Universal apps & CUDA logic).

---
*Built for the 500 Subscriber Milestone. Join the Rabbit Hole!*

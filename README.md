# Jacob's NixOS Golden Build
Modular NixOS configuration for an AMD Ryzen 7 7800X3D and NVIDIA RTX 5070 (Blackwell).

## 🚀 Key Features
- **NixOS 25.11 (Xantusia)**: Tracking the stable release branch.
- **Blackwell Optimized**: Dedicated `nvidia.nix` using open-kernel modules and Linux 6.18.
- **Fast Boot**: Optimized GRUB timeouts and disabled network-wait-online (27s cold boot).
- **Modular Architecture**: Clean separation between creative tools, hardware, and system apps.

## 🛠️ Quick Commands
- `rebuild "msg"`: Auto-format, system switch, and git push.
- `maintenance`: Update flake inputs, rebuild, collect garbage, and optimize store.
- `showcase`: System overview with Fastfetch and config tree.
- `cleanup`: Delete system generations older than 7 days.

## 📂 Configuration Structure
- `flake.nix`: System entry point and input management.
- `nvidia.nix`: Specialized Blackwell driver logic.
- `creative.nix`: Production suite (DaVinci Resolve, OBS).
- `system-apps.nix`: Core system utilities and Brave browser.

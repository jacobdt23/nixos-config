# 󰑃 Jacob's NixOS Golden Build (2026)
Modular NixOS + Home Manager configuration for an AMD Ryzen 7 7800X3D and NVIDIA RTX 5070 (Blackwell), featuring both KDE Plasma 6 and a Tokyo Night Hyprland desktop.

## 🚀 Key Features
- **Modular Flake Switchboard**: Build for **Physical Metal (`#nixos`)** or a lightweight **Virtual Machine (`#vm`)** from a single repository.
- **Blackwell Optimized**: Dedicated `nvidia.nix` using open-kernel modules, `nvidiaPackages.production`, and Wayland session variables.
- **Scoped CUDA & Cachix**: Scoped CUDA support for OBS Studio + `nix-community` binary cache so rebuilds don't compile massive packages from source.
- **Dual Desktop Ready**: SDDM Wayland configured with both **KDE Plasma 6** and **Hyprland** (Tokyo Night theme).
- **Creative & Gaming Suites**: Modular `creative.nix` (DaVinci Resolve Studio, OBS with NVENC/CUDA, `drs-fix`) and `gaming.nix` (Steam, GameMode, ProtonUp-Qt, MangoHUD, `scx_lavd`).

## 🛠 Quick Commands
- `rebuild`: Auto-detects hostname (`nixos` or `vm`), commits changes, switches flake, and pushes to GitHub.
- `nrs` / `hms`: `sudo nixos-rebuild switch --flake ~/GitHub/nixos-config#nixos --impure`
- `cleanup`: Delete old generations and optimize the Nix store.

## 📂 Configuration Structure
- `flake.nix`: The "Switchboard" defining `#nixos` and `#vm` host profiles.
- `configuration.nix`: Universal system core (Bootloader, Kernel, ZRAM, PipeWire, Bluetooth, KVM/QEMU, SDDM, Integrated Home Manager).
- `nvidia.nix`: RTX 5070 Blackwell drivers and Wayland variables.
- `creative.nix`: DaVinci Resolve Studio, OBS Studio (with CUDA), and `drs-fix`.
- `gaming.nix`: Steam, GameMode, MangoHUD, ProtonUp-Qt, and `scx` schedulers.
- `system-apps.nix`: Universal CLI and desktop applications.
- `home.nix`: Home Manager core (Bash aliases, `rebuild` function, `direnv`/`nix-direnv`, Git LFS, Fastfetch).
- `modules/home/`: Modular Tokyo Night Hyprland desktop suite:
  - `hyprland.nix`: Hyprland WM settings, keybinds, window/layer rules, and packaged `hypr-screenshot` / `hypr-clipboard` scripts.
  - `waybar.nix`: Top bar and bottom dock configuration & CSS.
  - `rofi.nix`: Application launcher configuration & Tokyo Night theme.
  - `kitty.nix`: Kitty terminal configuration.
  - `dunst.nix`: Dunst notification daemon configuration.
  - `hyprlock.nix`: Hyprlock lock screen and Hyprpaper wallpaper configuration.

---
*Built for the 500 Subscriber Milestone. Join the Rabbit Hole!*

# nixos-config

My personal NixOS and Home Manager configuration.

## Hardware
- **CPU**: AMD Ryzen 7 7800X3D
- **GPU**: NVIDIA GeForce RTX 5070

## Desktop Environments
- **KDE Plasma 6**: Desktop environment
- **Hyprland**: Wayland tiling window manager
- **Qtile**: Python-based window manager with custom status bar

## Repository Layout
- `flake.nix` - Flake inputs and host definitions (`nixos` for bare metal, `vm` for test lab)
- `configuration.nix` - Core system config (kernel, audio, networking, services)
- `hardware-configuration.nix` - Hardware scan and filesystem mounts
- `nvidia.nix` - NVIDIA driver settings and Wayland variables
- `creative.nix` - DaVinci Resolve Studio & OBS Studio with CUDA/NVENC
- `gaming.nix` - Steam, GameMode, MangoHUD, and sched-ext schedulers
- `system-apps.nix` - System-wide packages
- `home.nix` - Base Home Manager user environment and shell aliases
- `modules/home/` - User-level desktop configurations (Hyprland, Qtile, Waybar, Kitty, Dunst, Rofi)

## Usage

Rebuild and switch configuration:
```bash
sudo nixos-rebuild switch --flake .#nixos
```

Or using the shell helper:
```bash
rebuild
```

To clean up old generations:
```bash
cleanup
```

# HyprFrost NixOS (`nixos-config`)

My custom Omarchy-esque NixOS & Home Manager configuration — including a bootable **HyprFrost NixOS Live ISO** with Calamares, Hyprland, Tokyo Night, Colloid-Dark icons, and local AI tooling.

## Hardware
- **CPU**: AMD Ryzen 7 7800X3D
- **GPU**: NVIDIA GeForce RTX 5070

## Desktop Environments
- **Hyprland**: Omarchy-esque Tokyo Night desktop (Waybar, Rofi, Dunst, Kitty, Quickshell right-pinned keybindings background layer, Colloid-Dark icons)
- **Qtile**: Python-based window manager with custom status bar

## Repository Layout
- `flake.nix` — Flake inputs and targets (`nixos` bare metal, `vm` test lab, `iso` bootable live ISO, plus reusable `nixosModules.hyprfrost`)
- `configuration.nix` — Core HyprFrost NixOS system config, OS branding, kernel, audio, networking, and services
- `iso.nix` — Custom bootable live ISO module (Calamares graphical installer, auto-login into Hyprland, preloaded flake at `/etc/hyprfrost-flake`)
- `hardware-configuration.nix` — Hardware scan and filesystem mounts
- `nvidia.nix` — NVIDIA driver settings and Wayland variables
- `creative.nix` — DaVinci Resolve Studio & OBS Studio with CUDA/NVENC
- `gaming.nix` — Steam, GameMode, MangoHUD, and sched-ext schedulers
- `system-apps.nix` — System-wide packages
- `home.nix` — Home Manager environment (`fish`, `bash`, Colloid-Dark icons, `claude-lm`, LM Studio & Claude Desktop config)
- `modules/home/` — Hyprland, Qtile, Waybar, Rofi, Dunst, Kitty, Hyprlock, and the solid right-pinned keybindings layer

## Usage

Rebuild and switch on NixOS:
```bash
sudo nixos-rebuild switch --flake .#nixos
```

Or using the shell helper:
```bash
nrs
```

### Build the Custom HyprFrost NixOS ISO
On any Linux machine with Nix flakes enabled:
```bash
nix build .#iso
# Output: result/iso/hyprfrost-nixos-x86_64.iso
```

Test the ISO in QEMU:
```bash
qemu-system-x86_64 -enable-kvm -smp 4 -m 4096 -cdrom result/iso/hyprfrost-nixos-x86_64.iso
```

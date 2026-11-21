{ config, pkgs, lib, modulesPath, ... }:

let
  hyprfrost-install = pkgs.writeShellScriptBin "hyprfrost-install" ''
    set -euo pipefail
    echo "=== HyprFrost NixOS Flake Installer ==="
    echo ""
    echo "Option 1 (Graphical): Run 'calamares' (or launch Install System from Rofi)"
    echo "Option 2 (Direct Flake Install after partitioning & mounting to /mnt):"
    echo "  sudo nixos-generate-config --root /mnt"
    echo "  sudo cp /mnt/etc/nixos/hardware-configuration.nix /tmp/hyprfrost-flake/"
    echo "  sudo nixos-install --flake /tmp/hyprfrost-flake#nixos"
    echo ""
    echo "The HyprFrost flake source is preloaded in /etc/hyprfrost-flake."
  '';
in
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares.nix"
  ];

  # --- Live ISO Identity & Compression ---
  networking.hostName = lib.mkForce "hyprfrost-iso";
  isoImage = {
    isoName = lib.mkForce "hyprfrost-nixos-x86_64.iso";
    volumeID = lib.mkForce "HYPRFROST_NIXOS";
    squashfsCompression = "zstd -Xcompression-level 15";
  };

  # Avoid conflicts with installation-cd / iso-image defaults
  boot.loader.grub.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  networking.wireless.enable = lib.mkForce false;
  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";

  # Auto-login straight into the Omarchy-esque Hyprland live desktop
  services.displayManager = {
    defaultSession = "hyprland";
    autoLogin = {
      enable = lib.mkForce true;
      user = lib.mkForce "jacob";
    };
  };

  users.users.jacob.password = lib.mkForce "hyprfrost";
  security.sudo.wheelNeedsPassword = lib.mkForce false;

  # Bundle this flake into the live ISO for offline/direct installs
  environment.etc."hyprfrost-flake".source = ./.;

  environment.systemPackages = with pkgs; [
    hyprfrost-install
    gparted
  ];
}

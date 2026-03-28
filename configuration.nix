{ config, pkgs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
    ./nvidia.nix
    ./system-apps.nix
  ];

  # Allow unfree packages for NVIDIA drivers
  nixpkgs.config.allowUnfree = true;

  # GRUB setup for dual-booting with Windows 11 on the second 990 PRO
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
  };

  # Switching to the latest stable kernel to fix the TTY/Display crash
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Indiana/Indianapolis";
  time.hardwareClockInLocalTime = true;

  users.users.jacob = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "libvirtd" ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "26.05";
}

{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ./nvidia.nix
      ./creative.nix
      ./system-apps.nix
    ];

  # Bootloader settings for dual-booting with Windows 11
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
  };

  # Kernel and Schedulers for 7800X3D
  boot.kernelPackages = pkgs.linuxPackages_xanmod; 

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Indiana/Indianapolis";
  time.hardwareClockInLocalTime = true;

  users.users.jacob = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "26.05";
}

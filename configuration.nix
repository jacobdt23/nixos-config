{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ./nvidia.nix
      ./system-apps.nix
      # creative.nix removed as it is missing from your directory
    ];

  # Allow unfree packages (Required for NVIDIA drivers)
  nixpkgs.config.allowUnfree = true;

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true; # Keeps Windows 11 on the second 990 PRO visible
  };

  # High-performance kernel for your 7800X3D
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

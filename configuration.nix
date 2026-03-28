{ config, pkgs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
    ./nvidia.nix
    ./system-apps.nix
  ];

  nixpkgs.config.allowUnfree = true;

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
  };

  # Testing with latest stable kernel to prevent Xanmod/Nvidia reboots
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

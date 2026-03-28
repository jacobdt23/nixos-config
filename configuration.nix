{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ./nvidia.nix
      ./system-apps.nix
      # Removed creative.nix because it is missing from the folder
    ];

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
  };

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

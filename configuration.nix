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

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  
  # DNS FIX: Use Google and Cloudflare DNS to ensure NVIDIA servers resolve
  networking.nameservers = [ "8.8.8.8" "1.1.1.1" ];
  services.resolved.enable = true;

  time.timeZone = "America/Indiana/Indianapolis";
  time.hardwareClockInLocalTime = true;

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  users.users.jacob = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "libvirtd" ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "26.05";
}

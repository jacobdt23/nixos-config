{ config, pkgs, ... }:

{
  imports = [   
    ./hardware-configuration.nix
    ./nvidia.nix
    ./system-apps.nix
    ./creative.nix
  ];

  # --- Nix System Management ---
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true; 
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # --- Bootloader ---
  boot.loader.grub = {
    enable = true;
    device = "nodev"; # "nodev" is correct for EFI systems
    efiSupport = true;
    useOSProber = false; # Cleaned up PikaOS entries
    configurationLimit = 10;
  };

  boot.loader.efi.canTouchEfiVariables = true;

  # --- Storage ---
  # This mounts your 2TB Samsung 990 PRO to /mnt/GAMES
  fileSystems."/mnt/GAMES" = {
    device = "/dev/disk/by-uuid/c7cd2f66-a823-4cc7-8f24-b64bed83a67c";
    fsType = "ext4";
    options = [ "defaults" "nofail" "user" ];
  };

  # Fix for Hogwarts Legacy map/freezing
  boot.kernel.sysctl = { "vm.max_map_count" = 2147483642; };

  # --- Networking & Localization ---
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "America/Indiana/Indianapolis";
  i18n.defaultLocale = "en_US.UTF-8";

  # --- Desktop Environment (KDE Plasma 6) ---
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  
  # Set US Keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # --- Hardware & Sound ---
  services.printing.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # --- User Account ---
  users.users.jacob = {
    isNormalUser = true;
    description = "jacob";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
  };

  # --- Global App Settings ---
  nixpkgs.config.allowUnfree = true;

  # Home Manager Integration
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.jacob = import ./home.nix;

  system.stateVersion = "25.11";  
}

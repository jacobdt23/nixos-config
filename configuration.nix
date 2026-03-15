{ config, pkgs, lib, inputs, ... }:

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
    # Binary Cache for COSMIC (Avoids massive Rust compile times)
    substituters = [ "https://cosmic.cachix.org/" ];
    trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # --- Bootloader ---
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = false;
    configurationLimit = 10;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # --- Performance Boot Tweaks ---
  boot.loader.timeout = 1; 
  systemd.network.wait-online.enable = false;
  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;

  # --- Storage ---
  fileSystems."/mnt/GAMES" = {
    device = "/dev/disk/by-uuid/c7cd2f66-a823-4cc7-8f24-b64bed83a67c";
    fsType = "ext4";
    options = [ "defaults" "nofail" "user" ];
  };

  # Optimized for 7800X3D & Heavy Games
  boot.kernel.sysctl = { "vm.max_map_count" = 2147483642; };

  # --- Networking & Localization ---
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "America/Indiana/Indianapolis";
  i18n.defaultLocale = "en_US.UTF-8";

  # --- Primary Desktop Environment (KDE Plasma 6) ---
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # --- SPECIALISATION: COSMIC DESKTOP ---
  # Using SDDM bypass and core-only install to avoid hash mismatches
  specialisation."COSMIC".configuration = {
    system.nixos.tags = [ "COSMIC" ];

    # Disable Plasma 6 for this boot entry
    services.desktopManager.plasma6.enable = lib.mkForce false;

    # Enable COSMIC Core
    services.desktopManager.cosmic.enable = true;
    
    # Disable the experimental/broken COSMIC apps and greeter
    services.displayManager.cosmic-greeter.enable = lib.mkForce false;
    # Use standard SDDM instead
    services.displayManager.sddm.enable = lib.mkForce true;

    # NVIDIA Blackwell fix for cosmic-comp
    boot.kernelParams = [ "nvidia_drm.fbdev=1" ];
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

  # --- Global App & Home Manager Settings ---
  nixpkgs.config.allowUnfree = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.jacob = import ./home.nix;
    extraSpecialArgs = { inherit inputs; };
  };

  system.stateVersion = "25.11";
}

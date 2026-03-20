{ config, pkgs, lib, inputs, ... }:

{
  imports = [ ./system-apps.nix ];

  nixpkgs.config.allowUnfree = true;

  # --- CACHYOS PEAK PERFORMANCE ---
  # Using the specific Zen 4 LTO kernel found in your 'nix flake show'
  boot.kernelPackages = pkgs.linuxPackages_cachyos-latest-lto-zen4;
  
  # Enable Sched-ext (The gaming scheduler)
  services.scx.enable = true;
  services.scx.scheduler = "scx_lavd"; # Best for 7800X3D

  # Binary Cache (Vital to avoid a 3-hour kernel compile)
  nix.settings = {
    substituters = [ "https://nix-cachyos-kernel.cachix.org" ];
    trusted-public-keys = [ "nix-cachyos-kernel.cachix.org-1:99NooIAs9V65063g28yE8h4fP3T8vQvO8S6K2m0VfL8=" ];
  };

  # --- ZRAM (Optimized 16GB for 32GB RAM) ---
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # --- Boot/System Basics ---
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  networking.hostName = "nixos";
  time.timeZone = "America/Indiana/Indianapolis";
  
  users.users.jacob = {
    isNormalUser = true;
    description = "Jacob Turner";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.jacob = import ./home.nix;
    extraSpecialArgs = { inherit inputs; };
  };

  system.stateVersion = "25.11";
}

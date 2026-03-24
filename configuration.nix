{ config, pkgs, lib, inputs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
    ./system-apps.nix 
    ./nvidia.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # --- CACHYOS ZEN 4 PERFORMANCE ---
  # Optimizes the kernel specifically for your Ryzen 7 7800X3D
  boot.kernelPackages = pkgs.linuxPackagesFor inputs.nix-cachyos-kernel.packages.${pkgs.system}.linux-cachyos-lts-zen4;

  # --- SCHED-EXT (Gaming & Productivity) ---
  services.scx.enable = true;
  services.scx.scheduler = "scx_lavd";

  # --- NIX SETTINGS ---
  nix.settings = {
    substituters = [ "https://nix-cachyos-kernel.cachix.org" ];
    trusted-public-keys = [ "nix-cachyos-kernel.cachix.org-1:99NooIAs9V65063g28yE8h4fP3T8vQvO8S6K2m0VfL8=" ];
    experimental-features = [ "nix-command" "flakes" ];
    
    # Automatically hard-link duplicate files to save disk space
    auto-optimise-store = true;
  };

  # --- AUTO MAINTENANCE ---
  # Keeps your 1.79 TiB drive from filling up with old generations
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # --- SYSTEM BOOT ---
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # --- DESKTOP ENVIRONMENT (KDE Plasma 6) ---
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # --- NETWORKING & LOCALE ---
  # lib.mkDefault allows the Flake to override this (e.g., to "vm")
  networking.hostName = lib.mkDefault "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "America/Indiana/Indianapolis";

  # --- USER SETUP ---
  users.users.jacob = {
    isNormalUser = true;
    description = "Jacob Turner";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
  };

  # --- HOME MANAGER ---
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.jacob = import ./home.nix;
    extraSpecialArgs = { inherit inputs; };
  };

  system.stateVersion = "25.11";
}

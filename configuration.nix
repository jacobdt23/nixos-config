{ config, pkgs, lib, inputs, ... }:

{
  imports = [ ./system-apps.nix ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ "ventoy-1.1.10" ];

  # --- CACHYOS PERFORMANCE STACK ---
  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  
  # Enable Sched-ext (The CachyOS gaming scheduler)
  services.scx.enable = true;
  services.scx.scheduler = "scx_lavd"; # Best for Ryzen 7800X3D

  # --- Binary Cache (Avoid compiling the kernel manually) ---
  nix.settings = {
    substituters = [ "https://nix-cachyos-kernel.cachix.org" ];
    trusted-public-keys = [ "nix-cachyos-kernel.cachix.org-1:99NooIAs9V65063g28yE8h4fP3T8vQvO8S6K2m0VfL8=" ];
  };

  # --- ZRAM (Optimized for 32GB RAM) ---
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  # --- Bootloader ---
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # --- Desktop Environment ---
  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true; 
  };
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

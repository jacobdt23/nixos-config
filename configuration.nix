{ config, pkgs, lib, inputs, ... }:

{
  imports = [ ./system-apps.nix ];

  nixpkgs.config.allowUnfree = true;

  # --- CACHYOS ZEN 4 PERFORMANCE ---
  # Using the direct path from inputs to bypass attribute errors
  boot.kernelPackages = pkgs.linuxPackagesFor inputs.nix-cachyos-kernel.packages.${pkgs.system}.linux-cachyos-latest-lto-zen4;
  
  # Gaming Scheduler for 7800X3D snappiness
  services.scx.enable = true;
  services.scx.scheduler = "scx_lavd";

  # Binary Cache (Vital for speed)
  nix.settings = {
    substituters = [ "https://nix-cachyos-kernel.cachix.org" ];
    trusted-public-keys = [ "nix-cachyos-kernel.cachix.org-1:99NooIAs9V65063g28yE8h4fP3T8vQvO8S6K2m0VfL8=" ];
  };

  # --- ZRAM (16GB Swap for 32GB RAM) ---
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # --- Standard System Logic ---
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

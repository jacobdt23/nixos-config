{ config, pkgs, lib, inputs, ... }:

{
  imports = [ ./system-apps.nix ];

  nixpkgs.config.allowUnfree = true;

  # --- PERFORMANCE KERNEL (XanMod) ---
  # Replaces CachyOS to fix the 404 error; still supports scx/gaming
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  services.scx.enable = true;
  services.scx.scheduler = "scx_lavd";

  # --- NIX SETTINGS ---
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    substituters = [ "https://cache.nixos.org" ];
  };

  # --- AUTO MAINTENANCE ---
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # --- SYSTEM SETUP ---
  zramSwap.enable = true;
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  networking.hostName = lib.mkDefault "nixos";
  networking.networkmanager.enable = true;
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

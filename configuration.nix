{ config, pkgs, lib, inputs, ... }:

{
  imports = [ ./system-apps.nix ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [ "ventoy-1.1.10" ];

  # --- Nix Settings ---
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  
  # --- ZRAM (Fixed for 32GB Rig) ---
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
    wayland.enable = true; # Forces Wayland to avoid Blackwell X11 crashes
  };
  services.desktopManager.plasma6.enable = true;

  # --- Networking & Localization ---
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "America/Indiana/Indianapolis";
  i18n.defaultLocale = "en_US.UTF-8";

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

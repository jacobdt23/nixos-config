{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./system-apps.nix
  ];

  nixpkgs.config.allowUnfree = true;

  # --- Bootloader & Kernel ---
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # --- ZRAM ---
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  # --- Virtualization (KVM/QEMU) ---
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # --- Scheduler ---
  services.scx.enable = true;
  services.scx.scheduler = "scx_lavd";

  # --- Networking & DNS ---
  networking.hostName = lib.mkDefault "nixos";
  networking.networkmanager.enable = true;

  # DNS FIX: Use Google and Cloudflare DNS to ensure NVIDIA servers resolve
  networking.nameservers = [ "8.8.8.8" "1.1.1.1" ];
  services.resolved.enable = true;

  # --- Time & Localization ---
  time.timeZone = "America/Indiana/Indianapolis";
  time.hardwareClockInLocalTime = true;
  i18n.defaultLocale = "en_US.UTF-8";

  # --- Desktop Environment ---
  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.desktopManager.plasma6.enable = true;
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # --- Users & Home Manager Integration ---
  users.users.jacob = {
    isNormalUser = true;
    description = "Jacob Turner";
    extraGroups = [ "wheel" "networkmanager" "video" "libvirtd" ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    users.jacob = import ./home.nix;
  };

  # --- Nix Settings & Garbage Collection ---
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.stateVersion = "25.11";
}

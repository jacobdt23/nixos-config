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

  # --- Audio (PipeWire) & Bluetooth ---
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # --- Desktop Environment & Window Managers ---
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
  services.xserver.windowManager.qtile = {
    enable = true;
    extraPackages = python3Packages: with python3Packages; [
      psutil
      dbus-next
      pyxdg
    ];
  };

  # --- Users & Home Manager Integration ---
  users.users.jacob = {
    isNormalUser = true;
    description = "Jacob Turner";
    extraGroups = [ "wheel" "networkmanager" "video" "audio" "libvirtd" ];
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
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.stateVersion = "25.11";
}

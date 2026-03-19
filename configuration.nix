{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    # We only import the universal app list here. 
    # nvidia.nix and creative.nix are now called by flake.nix based on the host.
    ./system-apps.nix
  ];

  # --- Global Nix Settings ---
  nixpkgs.config.allowUnfree = true;
  
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;

    # Optimized build intensity for your 32GB RAM
    max-jobs = 4;
    cores = 2;

    substituters = [ "https://cosmic.cachix.org/" ];
    trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
  };

  # --- Memory Management (ZRAM) ---
  # Essential for 4K editing in Resolve on 32GB RAM
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  # Fix for the "Device zram0 not found" conflict with systemd-generators
  systemd.services."systemd-zram-setup@zram0".enable = lib.mkForce false;

  # --- Bootloader (Dual-Boot Optimization) ---
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true; # Finds Windows 11 on your other NVMe
    configurationLimit = 10;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;
  
  # Speed up boot by not waiting for a network that might not be there
  systemd.network.wait-online.enable = false;

  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642; # Hogwarts Legacy / Steam fix
    "vm.swappiness" = 10;           # Prefer RAM over swap
  };

  # --- Networking & Localization ---
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "America/Indiana/Indianapolis";
  i18n.defaultLocale = "en_US.UTF-8";
  
  # Keeps Windows and Linux clocks in sync across your NVMe drives
  time.hardwareClockInLocalTime = true;

  # --- Desktop Environment (KDE Plasma 6) ---
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # --- Audio (Pipewire for HyperX Cloud III) ---
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
    description = "Jacob Turner";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
  };

  # --- Home Manager ---
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.jacob = import ./home.nix;
    extraSpecialArgs = { inherit inputs; };
  };

  # --- Cleanup & Maintenance ---
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.stateVersion = "25.11";
}

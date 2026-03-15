{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ./system-apps.nix
    ./creative.nix
    # ./cosmic.nix # Commented out until base system is stable and upstream fixes are in
  ];

  # --- Nix System Management ---
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    
    # STABILITY: Prevent RAM spikes on your 32GB system during builds
    # This keeps the 7800X3D from overwhelming the memory bus
    max-jobs = 4; 
    cores = 2;    

    substituters = [ "https://cosmic.cachix.org/" ];
    trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
  };

  # NUCLEAR STABILITY: Disable the aggressive OOM killer "Bouncer"
  # This stops Brave and Terminal from being killed during high-pressure builds
  systemd.oomd.enable = false;
  systemd.oomd.enableUserSlices = false;

  # ENABLE high-priority compressed RAM swap (16GB safety buffer)
  zramSwap = {
    enable = true;
    priority = 100;
    memoryPercent = 50; 
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
  boot.loader.timeout = 1;
  systemd.network.wait-online.enable = false;

  # --- Storage & Kernel Tweaks ---
  boot.kernel.sysctl = { 
    "vm.max_map_count" = 2147483642; # Hogwarts Legacy / UE5 fix
    "vm.swappiness" = 10;            # Prefer RAM over swap for responsiveness
  };

  # --- Networking & Localization ---
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "America/Indiana/Indianapolis";
  i18n.defaultLocale = "en_US.UTF-8";

  # --- Desktop Environment (KDE Plasma 6) ---
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb = {
    layout = "us";
    variant = "";
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

  # --- Home Manager Integration ---
  nixpkgs.config.allowUnfree = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.jacob = import ./home.nix;
    extraSpecialArgs = { inherit inputs; };
  };

  system.stateVersion = "25.11";
}

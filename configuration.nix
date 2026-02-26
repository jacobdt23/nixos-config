{ config, pkgs, ... }:

{
  imports = [  
    ./hardware-configuration.nix
    ./nvidia.nix
    ./system-apps.nix
    ./creative.nix
  ];

  # --- Nix System Management ---
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true; # Keeps that 7.5GB you just freed from coming back
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # --- Bootloader & Kernel ---
  boot.loader.grub = {
    enable = true;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
    configurationLimit = 10;
    extraEntries = ''
      menuentry "PikaOS (rEFInd)" {
        insmod part_gpt
        insmod fat
        search --no-floppy --fs-uuid --set=root 5747-B54B
        chainloader /EFI/refind/refind_x64.efi
      }
    '';
  };

  # Fix for Hogwarts Legacy map/freezing
  boot.kernel.sysctl = { "vm.max_map_count" = 2147483642; };

  # --- Networking & Localization ---
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "America/Indiana/Indianapolis";
  i18n.defaultLocale = "en_US.UTF-8";

  # --- Desktop Environment (KDE Plasma 6) ---
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  
  # Set US Keymap
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
    # Note: Using your actual password set during install. 
    # initialPassword is removed now for host security.
  };

  # --- Global App Settings ---
  nixpkgs.config.allowUnfree = true;

  # Home Manager Integration
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.jacob = import ./home.nix;

  system.stateVersion = "25.11"; 
}

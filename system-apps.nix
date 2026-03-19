{ pkgs, lib, config, ... }:

{
  # --- Global App Config ---
  nixpkgs.config.allowUnfree = true;
  
  # SMART CUDA TOGGLE: Only enable CUDA if Nvidia drivers are in the current host build.
  # This prevents VM builds from failing due to missing Nvidia/CUDA dependencies.
  nixpkgs.config.cudaSupport = lib.elem "nvidia" config.services.xserver.videoDrivers;

  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.10"
  ];

  # --- System Performance ---
  programs.gamemode.enable = true;

  # --- Universal Package List ---
  environment.systemPackages = with pkgs; [
    # Monitoring & Hardware
    nvtopPackages.full
    mangohud
    pciutils
    fastfetch
    tree
    vulkan-tools
    gnome-disk-utility
    linuxPackages_zen.cpupower

    # Daily Drivers & Productivity
    brave
    discord
    neovide
    nixpkgs-fmt
    kdePackages.kate
    git
    github-desktop
    wget
    curl
    ventoy
    protonup-qt
  ];

  # --- OBS Studio (With Hardware-Aware Override) ---
  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio.override {
      ffmpeg = pkgs.ffmpeg_7-full;
      # Automatically toggles CUDA support based on the hardware presence
      cudaSupport = lib.elem "nvidia" config.services.xserver.videoDrivers;
    };
    plugins = with pkgs.obs-studio-plugins; [
      obs-vaapi
      obs-vkcapture
      obs-pipewire-audio-capture
    ];
  };

  # --- Gaming ---
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Useful for Steam Deck/Remote play
    dedicatedServer.openFirewall = true;
  };
}

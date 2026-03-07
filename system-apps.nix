{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.cudaSupport = true;

  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    # --- Standard Apps ---
    brave
    neovide
    nixpkgs-fmt
    kdePackages.kate
    git
    github-desktop
    emacs
    wget
    curl
    pciutils
    fastfetch
    tree
    discord

    # --- Performance & Gaming ---
    nvtopPackages.full
    mangohud
    protonup-qt
    vulkan-tools
    gnome-disk-utility
    # Fix: cpupower is inside the kernel packages
    linuxPackages_zen.cpupower
  ];

  # OBS Studio (Blackwell/NVENC Optimized)
  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio.override {
      ffmpeg = pkgs.ffmpeg_7-full;
      cudaSupport = true;
    };
    plugins = with pkgs.obs-studio-plugins; [
      obs-vaapi
      obs-vkcapture
      obs-pipewire-audio-capture
    ];
  };

  programs.steam.enable = true;
}

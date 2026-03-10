{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.cudaSupport = true;

  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    # Performance & Monitoring
    nvtopPackages.full
    mangohud
    protonup-qt
    vulkan-tools
    gnome-disk-utility
    linuxPackages_zen.cpupower # Direct reference for your Zen kernel
    
    # Standard Apps
    brave
    neovide
    nixpkgs-fmt
    kdePackages.kate
    git
    github-desktop
    discord
    wget
    curl
  ];

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

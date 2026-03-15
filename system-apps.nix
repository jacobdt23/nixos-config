{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.cudaSupport = true;

  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.10"
  ];

  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    # Monitoring
    nvtopPackages.full
    mangohud
    pciutils
    fastfetch
    tree
    
    # Tech Apps
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
    vulkan-tools
    gnome-disk-utility
    
    # System Tools
    linuxPackages_zen.cpupower
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

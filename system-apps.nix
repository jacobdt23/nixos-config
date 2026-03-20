{ pkgs, lib, config, ... }:

{
  nixpkgs.config.cudaSupport = lib.elem "nvidia" config.services.xserver.videoDrivers;

  environment.systemPackages = with pkgs; [
    (if lib.elem "nvidia" config.services.xserver.videoDrivers
    then nvtopPackages.full
    else nvtopPackages.amd)

    mangohud
    fastfetch
    tree
    brave
    discord
    git
    neovide
    nixpkgs-fmt
    kdePackages.kate
    github-desktop
    wget
    curl
    protonup-qt
  ];

  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio.override {
      ffmpeg = pkgs.ffmpeg_7-full;
      cudaSupport = lib.elem "nvidia" config.services.xserver.videoDrivers;
    };
  };

  programs.steam.enable = true;
  programs.gamemode.enable = true;
}

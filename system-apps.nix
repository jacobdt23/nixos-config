{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

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

    # --- Hardware & Gaming ---
    protonup-qt
    mangohud
    nvtopPackages.full
    goverlay
    vulkan-tools
    gnome-disk-utility
  ];

  # THE OFFICIAL OBS MODULE
  # This handles the LD_LIBRARY_PATH and wrapper for you automatically.
  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio.override {
      ffmpeg = pkgs.ffmpeg_7-full;
    };
    plugins = with pkgs.obs-studio-plugins; [
      obs-vaapi
      obs-vkcapture
      obs-pipewire-audio-capture
    ];
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}

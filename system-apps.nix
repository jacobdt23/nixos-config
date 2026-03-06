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
    protonup-qt
    mangohud
    nvtopPackages.full
    goverlay
    vulkan-tools
    gnome-disk-utility
    tree
    discord

    # --- Wrapped OBS with Blackwell/NVENC Support ---
    (obs-studio.override {
      ffmpeg = ffmpeg_7-full;
    })
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}

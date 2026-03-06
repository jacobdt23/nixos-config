{ pkgs, ... }:

{
  # 1. Global unfree config for NVIDIA/Steam/Discord
  nixpkgs.config.allowUnfree = true;

  # 2. Neovim Configuration
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # 3. System-wide Package List
  environment.systemPackages = with pkgs; [
    # --- Standard Applications ---
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

    # --- Hardware & Gaming Tools ---
    protonup-qt
    mangohud
    nvtopPackages.full # Full NVIDIA/AMD monitoring
    goverlay
    vulkan-tools
    gnome-disk-utility

    # --- The "Golden" OBS Setup ---
    # This override ensures OBS is built with the full FFmpeg 7 
    # toolkit required for native Blackwell NVENC/AV1 support.
    (obs-studio.override {
      ffmpeg = ffmpeg_7-full;
    })
  ];

  # 4. Steam & Gaming Infrastructure
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}

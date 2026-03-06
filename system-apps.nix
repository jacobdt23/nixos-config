{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.cudaSupport = true;

  # Enable Gamescope with permissions to prioritize your game
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # Enable GameMode for CPU/GPU performance boosting
  programs.gamemode.enable = true;

  environment.systemPackages = with pkgs; [
    # --- Standard Apps ---
    brave neovide nixpkgs-fmt kdePackages.kate git
    github-desktop emacs wget curl pciutils fastfetch
    tree discord protonup-qt mangohud nvtopPackages.full
    goverlay vulkan-tools gnome-disk-utility
  ];

  # THE OFFICIAL OBS MODULE (Blackwell Optimized)
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

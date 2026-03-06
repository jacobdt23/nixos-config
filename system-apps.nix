{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.cudaSupport = true;

  # Enable Gamescope system-wide
  programs.gamescope = {
    enable = true;
    capSysNice = true; # Allows Gamescope to prioritize game threads
  };

  environment.systemPackages = with pkgs; [
    brave neovide nixpkgs-fmt kdePackages.kate git
    github-desktop emacs wget curl pciutils fastfetch
    tree discord protonup-qt mangohud nvtopPackages.full
    goverlay vulkan-tools gnome-disk-utility gamemode
  ];

  # THE OFFICIAL OBS MODULE
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

{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # Global CUDA support ensures FFmpeg and OBS can 'see' the 5070's cores
  nixpkgs.config.cudaSupport = true;

  environment.systemPackages = with pkgs; [
    # --- Standard Apps ---
    brave neovide nixpkgs-fmt kdePackages.kate git
    github-desktop emacs wget curl pciutils fastfetch
    tree discord
    
    # --- Hardware & Gaming ---
    protonup-qt mangohud goverlay vulkan-tools gnome-disk-utility
    nvtopPackages.full # Essential for monitoring Blackwell usage
  ];

  # THE "GOLDEN" OBS MODULE
  programs.obs-studio = {
    enable = true;
    # We override the package to force the FFmpeg 7 + CUDA handshake
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

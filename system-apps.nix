{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # Standard packages (REMOVED obs-studio from here)
  environment.systemPackages = with pkgs; [
    brave neovide nixpkgs-fmt kdePackages.kate git
    github-desktop emacs wget curl pciutils fastfetch
    tree discord protonup-qt mangohud nvtopPackages.full
    goverlay vulkan-tools gnome-disk-utility
  ];

  # THE OFFICIAL OBS MODULE (The "Better Way")
  programs.obs-studio = {
    enable = true;
    # This override is the secret sauce for NVENC on Blackwell
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

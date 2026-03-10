{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    davinci-resolve
    obs-studio
    vlc
    ffmpeg_7-full # For manual transcoding if AAC audio is silent
  ];

  # Force Resolve to see the PipeWire-ALSA bridge
  environment.sessionVariables = {
    ALSA_CARD = "Generic"; 
    LD_LIBRARY_PATH = [ "${pkgs.libpulseaudio}/lib" ];
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      libvdpau-va-gl
    ];
  };
}

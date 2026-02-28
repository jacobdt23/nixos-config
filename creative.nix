{ pkgs, ... }:

{
  # Allow the unfree DaVinci Resolve license
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    davinci-resolve # The heavy lifter
    obs-studio # For recording tutorials or streaming
    vlc # For checking renders
  ];

  # This is the "secret sauce" for Nvidia hardware acceleration in Resolve
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      libvdpau-va-gl
    ];
  };
}

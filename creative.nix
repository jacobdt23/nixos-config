{ pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # We use a 'ref' to customize the version if nixpkgs isn't updated yet
    (davinci-resolve-studio.override {
      # This ensures we are targeting the 20.x series logic
    })
    obs-studio
    vlc
  ];

  # Essential for Resolve to use your NVIDIA GPU for AI & Rendering
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      cudaPackages.cuda_nvcc
      libvdpau-va-gl
    ];
  };

  # Required for DaVinci Resolve's licensing and USB speed
  services.udev.extraRules = ''
    KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess"
  '';
}

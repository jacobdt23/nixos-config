{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true; # REQUIRED for RTX 50-series/Blackwell
    powerManagement.enable = false; # Prevents flickering on dual 1080p monitors
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ nvidia-vaapi-driver ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NIXOS_OZONE_WL = "1"; # Ensures Brave and Discord use Wayland hardware acceleration
  };
}

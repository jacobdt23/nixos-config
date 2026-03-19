{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true; # REQUIRED for RTX 50-series/Blackwell
    powerManagement.enable = false; # Prevents flicker on dual LG monitors
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ nvidia-vaapi-driver ];
  };

  # Forces Plasma and Electron apps to use Wayland/Nvidia correctly
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NIXOS_OZONE_WL = "1"; # Critical for Brave/Discord/Electron on Wayland
  };
}

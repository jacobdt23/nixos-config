{ config, pkgs, ... }:

{
  # 1. Enable the NVIDIA driver for the Xserver/Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Required for 50-series (Blackwell): Use the open-source kernel module
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    powerManagement.enable = true;
  };

  # 2. Hardware Acceleration & NVENC support (Corrected for 25.11)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  # 3. Environment Variables for OBS/Wayland
  environment.variables = {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  # 4. Blackwell Support: Target the 6.18 kernel
  boot.kernelPackages = pkgs.linuxPackages_6_18;
}

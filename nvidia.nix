{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  # CRITICAL: nvidia-drm.modeset=1 is required for Gamescope to launch on NVIDIA.
  # nvidia.NVreg_EnableGpuFirmware=0 fixes the 50-series FPS cap.
  boot.kernelParams = [ 
    "nvidia-drm.modeset=1" 
    "nvidia.NVreg_EnableGpuFirmware=0" 
  ];

  hardware.nvidia = {
    open = true; 
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true; # Required for Wayland/Gamescope
    powerManagement.enable = false;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __EGL_VENDOR_LIBRARY_FILENAMES = "/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json";
  };

  boot.kernelPackages = pkgs.linuxPackages_6_18;
}

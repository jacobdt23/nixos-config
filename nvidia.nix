{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  boot.kernelPackages = pkgs.linuxPackages_zen;

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    # "nvidia-drm.fbdev=1" # REMOVED: Often causes black screen on 50-series
    "nvidia.NVreg_EnableGpuFirmware=0"
    # SIMPLIFIED: Only set the basic high-perf source to avoid Blackwell firmware hitching
    "nvidia.NVreg_RegistryDwords=PerfLevelSrc=0x2222"
  ];

  hardware.nvidia = {
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
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
    # REMOVED: KWIN_DRM_USE_MODIFIERS="0" can cause Wayland login loops on newer drivers
  };
}

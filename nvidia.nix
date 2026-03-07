{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  # Zen kernel for superior frame pacing on the 7800X3D
  boot.kernelPackages = pkgs.linuxPackages_zen;

  boot.kernelParams = [ 
    "nvidia-drm.modeset=1" 
    "nvidia-drm.fbdev=1" 
    "nvidia.NVreg_EnableGpuFirmware=0" 
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
  };
}

{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  # UNLOCK BLACKWELL FPS: Disables GSP firmware which often caps 50-series FPS on Linux
  boot.kernelParams = [ "nvidia.NVreg_EnableGpuFirmware=0" ];

  hardware.nvidia = {
    open = true; # REQUIRED for Blackwell
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    # Disable experimental power management to prevent FPS drops
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
    # Force Wayland to use the NVIDIA EGL layer correctly
    __EGL_VENDOR_LIBRARY_FILENAMES = "/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json";
  };

  boot.kernelPackages = pkgs.linuxPackages_6_18;
}

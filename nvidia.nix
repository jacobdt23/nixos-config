{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  boot.kernelParams = [ 
    "nvidia-drm.modeset=1" 
    "nvidia-drm.fbdev=1" # Essential for Gamescope on KDE Wayland
    "nvidia.NVreg_EnableGpuFirmware=0" 
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1" # Prevents crashes on launch
  ];

  hardware.nvidia = {
    open = true; 
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
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
    # Helps Gamescope find the NVIDIA driver in the Nix store
    XDG_SESSION_TYPE = "wayland";
    NVD_BACKEND = "direct";
  };

  boot.kernelPackages = pkgs.linuxPackages_6_18;
}

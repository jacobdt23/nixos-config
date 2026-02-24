{ config, pkgs, ... }:

{
  # 1. Enable the NVIDIA driver in Xserver/Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # 2. Required for 50-series: Use the open-source kernel module
    open = true;

    # 3. Enable the Nvidia settings menu
    nvidiaSettings = true;

    # 4. Choose the driver version
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # 5. Enable Modesetting (required for Wayland)
    modesetting.enable = true;
  };

  # 6. Blackwell Support: Use the newer kernel
  boot.kernelPackages = pkgs.linuxPackages_6_18;
}

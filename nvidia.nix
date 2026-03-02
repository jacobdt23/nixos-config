{ config, pkgs, ... }:

{
  # 1. Enable the NVIDIA driver for the Xserver/Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # 2. Required for 50-series (Blackwell): Use the open-source kernel module
    open = true;

    # 3. Enable the Nvidia settings menu
    nvidiaSettings = true;

    # 4. Driver version: Using the stable branch for Blackwell
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # 5. Enable Modesetting (Mandatory for Wayland/Plasma 6)
    modesetting.enable = true;

    # 6. Power Management (Prevents flickering/glitches after sleep)
    powerManagement.enable = true;
  };

  # 7. Hardware Acceleration (For DaVinci Resolve & Firefox)
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Critical for Steam games
  };

  # 8. Blackwell Support: Target the 6.18 kernel for best compatibility
  boot.kernelPackages = pkgs.linuxPackages_6_18;
}

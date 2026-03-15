{ pkgs, lib, ... }:

{
  # This specialization is kept separate to prevent main system build failures
  specialisation."COSMIC".configuration = {
    system.nixos.tags = [ "COSMIC" ];

    # 1. Disable Plasma 6
    services.desktopManager.plasma6.enable = lib.mkForce false;

    # 2. Enable COSMIC Core
    services.desktopManager.cosmic.enable = true;

    # 3. Use SDDM for stability
    services.displayManager.sddm.enable = lib.mkForce true;
    services.displayManager.cosmic-greeter.enable = lib.mkForce false;

    # 4. Aggressive Exclusion List (Bypass current upstream build errors)
    environment.cosmic.excludePackages = with pkgs; [
      cosmic-edit
      cosmic-term
      cosmic-files
      cosmic-screenshot
      cosmic-settings
      cosmic-launcher
      cosmic-store
      cosmic-greeter
      cosmic-comp 
    ];

    # Blackwell (RTX 5070) Wayland Stability
    boot.kernelParams = [ "nvidia_drm.fbdev=1" ];
  };
}

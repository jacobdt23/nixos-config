{ config, pkgs, lib, inputs, ... }:

{
  imports = [ ./system-apps.nix ];

  nixpkgs.config.allowUnfree = true;

  # --- CACHYOS PERFORMANCE STACK ---
  boot.kernelPackages = pkgs.linuxPackages_cachyos;

  # Sched-ext (The "secret sauce" for 7800X3D gaming)
  services.scx.enable = true;
  services.scx.scheduler = "scx_lavd";

  # Binary Cache (Prevents your PC from compiling the kernel for 2 hours)
  nix.settings = {
    substituters = [ "https://nix-cachyos-kernel.cachix.org" ];
    trusted-public-keys = [ "nix-cachyos-kernel.cachix.org-1:99NooIAs9V65063g28yE8h4fP3T8vQvO8S6K2m0VfL8=" ];
  };

  # --- ZRAM (Fixed for 32GB) ---
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # ... [Keep the rest of your standard Bootloader/Plasma settings here] ...

  system.stateVersion = "25.11";
}

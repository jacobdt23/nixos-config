{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # --- Standard Apps ---
    brave neovide nixpkgs-fmt kdePackages.kate git
    github-desktop emacs wget curl pciutils fastfetch
    tree discord protonup-qt mangohud nvtopPackages.full
    goverlay vulkan-tools gnome-disk-utility

    # --- THE NUCLEAR OBS WRAPPER ---
    (obs-studio.overrideAttrs (oldAttrs: {
      postFixup = (oldAttrs.postFixup or "") + ''
        wrapProgram $out/bin/obs \
          --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib \
          --set LIBVA_DRIVER_NAME nvidia \
          --set XDG_SESSION_TYPE wayland
      '';
    }))
  ];

  programs.steam.enable = true;
}

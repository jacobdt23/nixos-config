{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    brave
    neovide
    nixpkgs-fmt
    kdePackages.kate
    git
    github-desktop
    emacs
    wget
    curl
    pciutils
    fastfetch
    protonup-qt
    mangohud
    nvtopPackages.full
    goverlay
    vulkan-tools
    gnome-disk-utility
    tree
    discord

    # --- Wrapped OBS with Blackwell/NVENC Driver Access ---
    (symlinkJoin {
      name = "obs-studio-wrapped";
      paths = [ obs-studio ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/obs \
          --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib \
          --set LIBVA_DRIVER_NAME nvidia
      '';
    })
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}

{ pkgs, lib, ... }:

let
  antigravity-fhs = pkgs.buildFHSEnv {
    name = "antigravity";
    targetPkgs = pkgs: (with pkgs; [
      alsa-lib
      at-spi2-atk
      at-spi2-core
      cairo
      cups
      dbus
      expat
      glib
      gtk3
      libdrm
      libGL
      libnotify
      libpulseaudio
      libuuid
      libxkbcommon
      mesa
      nspr
      nss
      pango
      systemd
      vulkan-loader
      xorg.libX11
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.libXrandr
      xorg.libXrender
      xorg.libXtst
      xorg.libxcb
    ]);
    runScript = "/opt/Antigravity/antigravity";
  };
in
{
  environment.systemPackages = [
    antigravity-fhs
  ];
}

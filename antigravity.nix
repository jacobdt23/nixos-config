{ pkgs, lib, ... }:

let
  pname = "antigravity";
  version = "2.29.1";

  # Download official Google Antigravity binary release
  antigravity-unwrapped = pkgs.stdenv.mkDerivation {
    inherit pname version;

    src = pkgs.fetchurl {
      url = "https://storage.googleapis.com/antigravity-public/antigravity-hub/${version}-5241471524274176/linux-x64/Antigravity.tar.gz";
      hash = "sha256-RnhgQlE5H+q4q3fm5aUj41C+aJgQ8zjHTV7c5pDkP6M=";
    };

    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/antigravity
      cp -a . $out/share/antigravity/
      chmod +x $out/share/antigravity/antigravity
      chmod +x $out/share/antigravity/chrome_crashpad_handler || true
      runHook postInstall
    '';
  };

  # FHS sandbox wrapper providing standard Linux library paths
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
      fontconfig
      freetype
      glib
      gtk3
      libdrm
      libepoxy
      libGL
      libgbm
      libnotify
      libpng
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
      zlib
    ]);

    runScript = pkgs.writeShellScript "antigravity-launcher" ''
      exec ${antigravity-unwrapped}/share/antigravity/antigravity --no-sandbox "$@"
    '';

    extraInstallCommands = ''
      mkdir -p $out/share/applications $out/share/pixmaps $out/share/icons/hicolor/512x512/apps
      cp ${./antigravity.desktop} $out/share/applications/antigravity.desktop
      cp ${./antigravity.png} $out/share/pixmaps/antigravity.png
      cp ${./antigravity.png} $out/share/icons/hicolor/512x512/apps/antigravity.png
    '';
  };
in
{
  environment.systemPackages = [
    antigravity-fhs
  ];
}

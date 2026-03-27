{ pkgs, lib, config, ... }:

let
  drs-fix = pkgs.writeShellScriptBin "drs-fix" ''
    if [ -z "$1" ]; then
        echo "Usage: drs-fix <filename>"
        exit 1
    fi
    INPUT="$1"
    # Use ''${ to tell Nix "this is a literal string, not a Nix variable"
    FILENAME=''${INPUT%.*}
    OUTPUT=''${FILENAME}_DRS.mov
    
    echo "🚀 Making clip Resolve-Ready: $INPUT"
    ${pkgs.ffmpeg_7-full}/bin/ffmpeg -i "$INPUT" -vcodec copy -acodec pcm_s16le "$OUTPUT"
    echo "✅ Success! Imported $OUTPUT into Resolve."
  '';
in
{
  nixpkgs.config.cudaSupport = lib.elem "nvidia" config.services.xserver.videoDrivers;

  environment.systemPackages = with pkgs; [
    (if lib.elem "nvidia" config.services.xserver.videoDrivers
    then nvtopPackages.full
    else nvtopPackages.amd)
    
    # --- System & CLI Tools ---
    bat
    mangohud
    fastfetch
    tree
    wget
    curl
    git
    nixpkgs-fmt
    alacritty
    # --- Emacs / Doom Emacs ---
    emacs
    ripgrep
    fd

    # --- GUI Apps ---
    brave
    discord
    kdePackages.kate
    github-desktop
    protonup-qt
    vlc

    # --- Creative & Video Editing ---
    davinci-resolve-studio
    ffmpeg_7-full
    drs-fix
  ];

  environment.sessionVariables = {
    ALSA_CARD = "Generic";
    LD_LIBRARY_PATH = [ "${pkgs.libpulseaudio}/lib" ];
  };

  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio.override {
      ffmpeg = pkgs.ffmpeg_7-full;
      cudaSupport = lib.elem "nvidia" config.services.xserver.videoDrivers;
    };
  };

  programs.steam.enable = true;
  programs.gamemode.enable = true;
}

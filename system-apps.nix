{ pkgs, lib, config, ... }:
let
  drs-fix = pkgs.writeShellScriptBin "drs-fix" ''
    if [ -z "$1" ]; then echo "Usage: drs-fix <filename>"; exit 1; fi
    INPUT="$1"; FILENAME=''${INPUT%.*}; OUTPUT=''${FILENAME}_DRS.mov
    ${pkgs.ffmpeg_7-full}/bin/ffmpeg -i "$INPUT" -vcodec copy -acodec pcm_s16le "$OUTPUT"
  '';
in
{
  # Smart CUDA support based on the active driver
  nixpkgs.config.cudaSupport = lib.elem "nvidia" config.services.xserver.videoDrivers;

  environment.systemPackages = with pkgs; [
    # GPU Monitoring
    (if lib.elem "nvidia" config.services.xserver.videoDrivers then nvtopPackages.full else nvtopPackages.amd)
    
    # CLI Essentials
    bat
    mangohud
    fastfetch
    tree
    wget
    curl
    git
    ripgrep
    fd
    wl-clipboard
    nixpkgs-fmt

    # Performance / Gaming
    scx.full
    gamemode
    protonup-qt

    # Desktop / Creative
    brave
    discord
    kdePackages.kate
    github-desktop
    vlc
    davinci-resolve-studio
    ffmpeg_7-full
    drs-fix

    # Dev / Editors
    neovim-qt 
    alacritty
    emacs
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

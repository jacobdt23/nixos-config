{ pkgs, lib, config, ... }:
let
  drs-fix = pkgs.writeShellScriptBin "drs-fix" ''
    if [ -z "$1" ]; then echo "Usage: drs-fix <filename>"; exit 1; fi
    INPUT="$1"; FILENAME=''${INPUT%.*}; OUTPUT=''${FILENAME}_DRS.mov
    ${pkgs.ffmpeg_7-full}/bin/ffmpeg -i "$INPUT" -vcodec copy -acodec pcm_s16le "$OUTPUT"
  '';
in
{
  nixpkgs.config.cudaSupport = lib.elem "nvidia" config.services.xserver.videoDrivers;

  environment.systemPackages = with pkgs; [
    (if lib.elem "nvidia" config.services.xserver.videoDrivers then nvtopPackages.full else nvtopPackages.amd)
    
    # Virtualization Support
    virt-viewer
    spice-gtk

    # CLI / System Tools
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

    # Neovim-Qt & Treesitter Dependencies
    neovim-qt
    gcc
    gnumake
    tree-sitter

    # Gaming / Creative
    scx.full
    gamemode
    protonup-qt
    brave
    discord
    kdePackages.kate
    github-desktop
    vlc
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

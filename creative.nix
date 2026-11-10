{ pkgs, lib, config, ... }:

let
  drs-fix = pkgs.writeShellScriptBin "drs-fix" ''
    if [ -z "$1" ]; then
      echo "Usage: drs-fix <filename>"
      exit 1
    fi
    INPUT="$1"
    FILENAME=''${INPUT%.*}
    OUTPUT=''${FILENAME}_DRS.mov
    echo "🚀 Making clip Resolve-Ready: $INPUT"
    ${pkgs.ffmpeg_7-full}/bin/ffmpeg -i "$INPUT" -vcodec copy -acodec pcm_s16le "$OUTPUT"
    echo "✅ Success! Output saved to $OUTPUT"
  '';
in
{
  environment.systemPackages = with pkgs; [
    davinci-resolve-studio
    ffmpeg_7-full
    drs-fix
    gimp
    vlc
  ];

  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio.override {
      ffmpeg = pkgs.ffmpeg_7-full;
      cudaSupport = lib.elem "nvidia" config.services.xserver.videoDrivers;
    };
  };
}

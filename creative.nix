{ pkgs, ... }:

let
  drs-fix = pkgs.writeShellScriptBin "drs-fix" ''
    if [ -z "$1" ]; then
        echo "Usage: drs-fix <filename>"
        exit 1
    fi
    INPUT="$1"
    FILENAME="''${INPUT%.*}"
    OUTPUT="''${FILENAME}_DRS.mov"
    echo "🚀 Making clip Resolve-Ready: $INPUT"
    ${pkgs.ffmpeg_7-full}/bin/ffmpeg -i "$INPUT" -vcodec copy -acodec pcm_s16le "$OUTPUT"
    echo "✅ Success! Imported $OUTPUT into Resolve."
  '';
in
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    davinci-resolve
    obs-studio
    vlc
    ffmpeg_7-full
    drs-fix
  ];

  environment.sessionVariables = {
    ALSA_CARD = "Generic"; 
    LD_LIBRARY_PATH = [ "${pkgs.libpulseaudio}/lib" ];
  };
}

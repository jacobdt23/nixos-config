{ config, pkgs, ... }:

let
  drs-fix = pkgs.writeShellScriptBin "drs-fix" ''
    if [ -z "$1" ]; then echo "Usage: drs-fix <filename>"; exit 1; fi
    ${pkgs.ffmpeg_7-full}/bin/ffmpeg -i "$1" -vcodec copy -acodec pcm_s16le "''${1%.*}_DRS.mov"
  '';
in
{
  home.username = "jacob";
  home.homeDirectory = "/home/jacob";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [ fastfetch tree drs-fix neovide ];

  programs.bash = {
    enable = true;
    initExtra = ''
      function rebuild {
        local host=$(hostname)
        local target="nixos"
        if [[ "$host" == "nixos-vm" ]]; then target="vm"; fi

        echo -e "\033[1;33m--- Syncing $target Config ---\033[0m"
        git -C ~/nixos-config add .
        git -C ~/nixos-config commit -m "Rebuild: $(date +'%Y-%m-%d %H:%M:%S')" || true
        
        nixpkgs-fmt ~/nixos-config/*.nix
        sudo nixos-rebuild switch --flake ~/nixos-config#$target --impure
      }
      fastfetch
    '';
    
    shellAliases = {
      l = "ls -alh";
      health = "nvidia-smi && echo '' && zramctl";
      cleanup = "sudo nix-collect-garbage --delete-older-than 7d";
    };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings.user = {
      name = "jacobdt23";
      email = "turnerjac01@gmail.com";
    };
  };

  programs.home-manager.enable = true;
}

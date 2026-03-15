{ config, pkgs, ... }:

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
  home.username = "jacob";
  home.homeDirectory = "/home/jacob";
  home.stateVersion = "25.11";

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # Neovim & Dev Tools
    lua-language-server
    nil
    stylua
    fd
    gcc
    unzip
    shellcheck
    pandoc
    
    # Multimedia
    drs-fix
    symbola
    nerd-fonts.symbols-only
  ];

  home.file = {
    ".config/neovide/config.toml".text = "fork = true";

    ".config/fastfetch/config.jsonc".text = ''
      {
        "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
        "logo": { "padding": { "top": 1 } },
        "display": { "separator": " 󰑃  " },
        "modules": [
          "break",
          { "type": "os", "key": " DISTRO", "keyColor": "yellow" },
          { "type": "kernel", "key": "│ ├", "keyColor": "yellow" },
          { "type": "packages", "key": "│ ├󰏖", "keyColor": "yellow" },
          { "type": "command", "key": "│ ├", "keyColor": "yellow", "text": "birth_install=$(stat -c %W /); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo $days_difference days" },
          { "type": "shell", "key": "│ └", "keyColor": "yellow" },
          { "type": "wm", "key": " DE/WM", "keyColor": "blue" },
          "wmtheme", "icons", "cursor", "terminal", "cpu", "gpu", "display", "memory", "uptime",
          { "type": "sound", "key": " AUDIO", "format": "{2}", "keyColor": "magenta" },
          "media",
          { "type": "custom", "format": "\u001b[90m  \u001b[31m  \u001b[32m  \u001b[33m  \u001b[34m  \u001b[35m  \u001b[36m  \u001b[37m  \u001b[38m  \u001b[39m  \u001b[39m    \u001b[38m  \u001b[37m  \u001b[36m  \u001b[35m  \u001b[34m  \u001b[33m  \u001b[32m  \u001b[31m  \u001b[90m " },
          "break"
        ]
      }
    '';
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      function rebuild {
        # Clean up editor saves before committing
        if ls ~/nixos-config/*.save 1> /dev/null 2>&1; then
           echo -e "\033[1;31m⚠️  Cleaning .save files...\033[0m"
           rm ~/nixos-config/*.save
        fi

        echo -e "\033[1;33m--- Syncing with GitHub ---\033[0m"
        git -C ~/nixos-config add .
        
        local gen=$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | grep current | awk '{print $1}')
        local timestamp=$(date +'%Y-%m-%d %H:%M:%S')
        local msg="''${1:-Gen $gen ($timestamp) Rebuild}"
        
        git -C ~/nixos-config commit -m "$msg" || true
        git -C ~/nixos-config pull --rebase

        echo -e "\033[1;34m--- Building NixOS Gen $((gen+1)) ---\033[0m"
        nixpkgs-fmt ~/nixos-config/*.nix

        if sudo nixos-rebuild switch --flake ~/nixos-config#nixos --impure; then
          git -C ~/nixos-config push
          echo -e "\n\033[1;32m🚀 Update complete!\033[0m\n"
        else
          echo -e "\n\033[1;31m❌ Rebuild failed.\033[0m\n"
          return 1
        fi
      }
      showcase
    '';

    shellAliases = {
      history = "git -C ~/nixos-config log --oneline -n 5";
      cleanup = "sudo nix-collect-garbage --delete-older-than 7d";
      listgens = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      showcase = "fastfetch && echo \"\" && tree ~/nixos-config";
      editconf = "neovide ~/nixos-config/configuration.nix > /dev/null 2>&1 & disown";
      edithome = "neovide ~/nixos-config/home.nix > /dev/null 2>&1 & disown";
      editapps = "neovide ~/nixos-config/system-apps.nix > /dev/null 2>&1 & disown";
      doom = "/home/jacob/.config/emacs/bin/doom";
      l = "ls -alh";
      ll = "ls -l";
    };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user.name = "jacobdt23";
      user.email = "turnerjac01@gmail.com";
    };
  };

  programs.home-manager.enable = true;
}

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
    lua-language-server
    nil
    stylua
    fd
    gcc
    unzip
    shellcheck
    pandoc
    drs-fix
    symbola
    nerd-fonts.symbols-only
    fastfetch
    tree
  ];

  # --- Managed Configuration Files ---
  home.file = {
    ".config/neovide/config.toml".text = "fork = true";

    # Professional Fastfetch Layout
    ".config/fastfetch/config.jsonc" = {
      force = true;
      text = ''
        {
          "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
          "logo": {
            "padding": {
              "top": 1
            }
          },
          "display": {
            "separator": " 󰑃  "
          },
          "modules": [
            "break",
            {
              "type": "os",
              "key": " DISTRO",
              "keyColor": "yellow"
            },
            {
              "type": "kernel",
              "key": "│ ├",
              "keyColor": "yellow"
            },
            {
              "type": "packages",
              "key": "│ ├󰏖",
              "keyColor": "yellow"
            },
            {
              "type": "command",
              "key": "│ ├",
              "keyColor": "yellow",
              "text": "birth_install=$(stat -c %W /); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo $days_difference days"
            },
            {
              "type": "shell",
              "key": "│ └",
              "keyColor": "yellow"
            },
            {
              "type": "wm",
              "key": " DE/WM",
              "keyColor": "blue"
            },
            {
              "type": "wmtheme",
              "key": "│ ├󰉼",
              "keyColor": "blue"
            },
            {
              "type": "icons",
              "key": "│ ├󰀻",
              "keyColor": "blue"
            },
            {
              "type": "cursor",
              "key": "│ ├",
              "keyColor": "blue"
            },
            {
              "type": "terminalfont",
              "key": "│ ├",
              "keyColor": "blue"
            },
            {
              "type": "terminal",
              "key": "│ └",
              "keyColor": "blue"
            },
            {
              "type": "host",
              "key": "󰌢 SYSTEM",
              "keyColor": "green"
            },
            {
              "type": "cpu",
              "key": "│ ├󰻠",
              "keyColor": "green"
            },
            {
              "type": "gpu",
              "key": "│ ├󰻑",
              "format": "{2}",
              "keyColor": "green"
            },
            {
              "type": "display",
              "key": "│ ├󰍹",
              "keyColor": "green",
              "compactType": "original-with-refresh-rate"
            },
            {
              "type": "memory",
              "key": "│ ├󰾆",
              "keyColor": "green"
            },
            {
              "type": "swap",
              "key": "│ ├󰓡",
              "keyColor": "green"
            },
            {
              "type": "uptime",
              "key": "│ ├󰅐",
              "keyColor": "green"
            },
            {
              "type": "sound",
              "key": " AUDIO",
              "format": "{2}",
              "keyColor": "magenta"
            },
            {
              "type": "player",
              "key": "│ ├󰥠",
              "keyColor": "magenta"
            },
            {
              "type": "media",
              "key": "│ └󰝚",
              "keyColor": "magenta"
            },
            {
              "type": "custom",
              "format": "\u001b[90m  \u001b[31m  \u001b[32m  \u001b[33m  \u001b[34m  \u001b[35m  \u001b[36m  \u001b[37m  \u001b[38m  \u001b[39m  \u001b[39m    \u001b[38m  \u001b[37m  \u001b[36m  \u001b[35m  \u001b[34m  \u001b[33m  \u001b[32m  \u001b[31m  \u001b[90m "
            },
            "break"
          ]
        }
      '';
    };
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      function rebuild {
        if ls ~/nixos-config/*.save 1> /dev/null 2>&1; then
           echo -e "\033[1;31m⚠️ Cleaning .save files...\033[0m"
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
      fastfetch
    '';

    shellAliases = {
      history = "git -C ~/nixos-config log --oneline -n 5";
      cleanup = "sudo nix-collect-garbage --delete-older-than 7d";
      listgens = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      showcase = "fastfetch && echo \"\" && tree ~/nixos-config";
      editconf = "neovide ~/nixos-config/configuration.nix > /dev/null 2>&1 & disown";
      edithome = "neovide ~/nixos-config/home.nix > /dev/null 2>&1 & disown";
      editapps = "neovide ~/nixos-config/system-apps.nix > /dev/null 2>&1 & disown";
      health = "nvidia-smi && echo '' && zramctl";
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

{ config, pkgs, ... }:

{
  home.username = "jacob";
  home.homeDirectory = "/home/jacob";
  home.stateVersion = "25.11";

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # Neovim & Support
    lua-language-server
    nil
    stylua
    ripgrep
    fd
    gcc
    unzip

    # Tech Tools
    fastfetch
    pciutils
    tree
    nixpkgs-fmt

    # Productivity & Creative
    kdePackages.kate
    shellcheck
    pandoc
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
      # THE ULTIMATE SMART REBUILD (v5 - Bulletproof Sync)
      function rebuild {
        git -C ~/nixos-config add .
        echo -e "\033[1;33m--- Syncing with GitHub ---\033[0m"
        git -C ~/nixos-config pull --rebase

        local files_changed=$(git -C ~/nixos-config diff --cached --name-only | tr '\n' ' ' | sed 's/ $//')
        local stats=$(git -C ~/nixos-config diff --cached --shortstat | sed 's/^ //')
        local gen=$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | grep current | awk '{print $1}')
        local timestamp=$(date +'%Y-%m-%d %H:%M:%S')

        if [ -z "$files_changed" ]; then
          local auto_msg="Gen $gen ($timestamp): Routine maintenance"
        else
          local auto_msg="Gen $gen ($timestamp): $files_changed | $stats"
        fi

        local msg="''${1:-$auto_msg}"

        echo -e "\033[1;34m--- Preparing NixOS Configs ($timestamp) ---\033[0m"
        nixpkgs-fmt ~/nixos-config/*.nix

        if sudo nixos-rebuild switch --flake ~/nixos-config#nixos; then
          git -C ~/nixos-config commit -m "$msg"
          git -C ~/nixos-config push
          echo -e "\n\033[1;32m🚀 Update complete: $msg\033[0m\n"
        else
          echo -e "\n\033[1;31m❌ Rebuild failed. No push to GitHub.\033[0m\n"
          return 1
        fi
      }

      # THE MAINTENANCE ENGINE (v1 - Deep Clean & Optimize)
      function maintenance {
        echo -e "\033[1;35m--- Starting Deep System Maintenance ---\033[0m"
        echo -e "\033[1;34mUpdating Flake inputs...\033[0m"
        nix flake update --flake ~/nixos-config
        
        rebuild "chore: weekly maintenance and flake update"

        echo -e "\033[1;33mCollecting Garbage...\033[0m"
        sudo nix-collect-garbage --delete-older-than 7d
        
        echo -e "\033[1;32mOptimising Nix Store...\033[0m"
        nix-store --optimise

        echo -e "\033[1;36m✨ Maintenance Complete! System is Golden. ✨\033[0m"
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

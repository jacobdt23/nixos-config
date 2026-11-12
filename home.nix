{ config, pkgs, ... }:

{
  imports = [
    ./modules/home/hyprland.nix
    ./modules/home/qtile.nix
  ];

  home.username = "jacob";
  home.homeDirectory = "/home/jacob";
  home.stateVersion = "25.11";

  # Hardwire wallpaper asset directly into ~/Pictures/Wallpapers/default.png
  home.file."Pictures/Wallpapers/default.png".source = ./assets/default.png;

  home.packages = with pkgs; [
    fastfetch
    tree
    wl-clipboard
    bat
  ];

  # Proper Home Manager integration for direnv + nix-direnv
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  # Git configuration
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings.user = {
      name = "jacobdt23";
      email = "turnerjac01@gmail.com";
    };
  };

  # --- CUSTOM FASTFETCH ---
  home.file.".config/fastfetch/config.jsonc".text = ''
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

  programs.bash = {
    enable = true;
    shellAliases = {
      sudo = "sudo ";
      ll = "ls -lah --color=auto";
      gs = "git status";
      config = "git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME";
    };

    initExtra = ''
      # Auto-detect NixOS config directory
      _get_nix_config_dir() {
        if [ -d "$HOME/github/nixos-config/.git" ]; then
          echo "$HOME/github/nixos-config"
        elif [ -d "$HOME/nixos-config/.git" ]; then
          echo "$HOME/nixos-config"
        elif [ -d "$HOME/GitHub/nixos-config/.git" ]; then
          echo "$HOME/GitHub/nixos-config"
        elif [ -d "$HOME/.config/nixos/.git" ]; then
          echo "$HOME/.config/nixos"
        elif [ -d "$HOME/nixos-config" ]; then
          echo "$HOME/nixos-config"
        else
          echo "$HOME/GitHub/nixos-config"
        fi
      }

      # Auto-detect flake target (vm vs nixos)
      _get_nix_target() {
        local host=$(hostname)
        if [[ "$host" == "vm" || "$host" == "nixos-vm" ]] || systemd-detect-virt -q 2>/dev/null; then
          echo "vm"
        else
          echo "nixos"
        fi
      }

      # Fast Rebuild / Switch Functions (Replaces old hardcoded aliases)
      nrs() {
        local cfg=$(_get_nix_config_dir)
        local target=$(_get_nix_target)
        echo -e "\033[1;34m--- Rebuilding NixOS ($target via $cfg) ---\033[0m"
        git -C "$cfg" add . 2>/dev/null || true
        sudo nixos-rebuild switch --flake "$cfg#$target" "$@"
      }

      hms() {
        nrs "$@"
      }

      nrb() {
        local cfg=$(_get_nix_config_dir)
        local target=$(_get_nix_target)
        echo -e "\033[1;34m--- Building NixOS Boot ($target via $cfg) ---\033[0m"
        git -C "$cfg" add . 2>/dev/null || true
        sudo nixos-rebuild boot --flake "$cfg#$target" "$@"
      }

      nix-test() {
        local cfg=$(_get_nix_config_dir)
        local target=$(_get_nix_target)
        echo -e "\033[1;34m--- Testing NixOS ($target via $cfg) ---\033[0m"
        git -C "$cfg" add . 2>/dev/null || true
        sudo nixos-rebuild test --flake "$cfg#$target" "$@"
      }

      nix-dry() {
        local cfg=$(_get_nix_config_dir)
        local target=$(_get_nix_target)
        echo -e "\033[1;34m--- Dry-building NixOS ($target via $cfg) ---\033[0m"
        nixos-rebuild dry-build --flake "$cfg#$target" "$@"
      }

      # Intercept 'nixos-rebuild' to auto-append flake if omitted
      nixos-rebuild() {
        if [[ "$1" == "switch" || "$1" == "boot" || "$1" == "test" || "$1" == "dry-build" ]] && [[ ! "$*" == *"--flake"* ]]; then
          local action="$1"
          shift
          local cfg=$(_get_nix_config_dir)
          local target=$(_get_nix_target)
          git -C "$cfg" add . 2>/dev/null || true
          command nixos-rebuild "$action" --flake "$cfg#$target" "$@"
        else
          command nixos-rebuild "$@"
        fi
      }

      # Intercept 'home-manager switch' to run unified rebuild
      home-manager() {
        if [[ "$1" == "switch" ]]; then
          shift
          nrs "$@"
        else
          command home-manager "$@"
        fi
      }

      # THE ULTIMATE SMART REBUILD (v6 - Dynamic Location & Target Detection)
      rebuild() {
        local CFG_DIR=$(_get_nix_config_dir)
        local TARGET=$(_get_nix_target)

        # 1. Stage changes immediately so pull/rebase works cleanly
        git -C "$CFG_DIR" add .

        # 2. Sync with GitHub
        echo -e "\033[1;33m--- Syncing with GitHub ---\033[0m"
        git -C "$CFG_DIR" pull --rebase || true

        # 3. Auto-detect what files changed
        local files_changed=$(git -C "$CFG_DIR" diff --cached --name-only | tr '\n' ' ' | sed 's/ $//')
        local stats=$(git -C "$CFG_DIR" diff --cached --shortstat | sed 's/^ //')

        # 4. System generation & timestamp info
        local gen=$(sudo nix-env --list-generations --profile /nix/var/nix/profiles/system | grep current | awk '{print $1}')
        local timestamp=$(date +'%Y-%m-%d %H:%M:%S')

        # 5. Build the commit message
        local auto_msg
        if [ -z "$files_changed" ]; then
          auto_msg="Gen $gen ($timestamp): Routine maintenance ($TARGET)"
        else
          auto_msg="Gen $gen ($timestamp): $files_changed | $stats"
        fi
        local msg="''${1:-$auto_msg}"

        echo -e "\033[1;34m--- Preparing NixOS Config ($TARGET @ $timestamp) ---\033[0m"
        if [ -n "$files_changed" ]; then
          echo -e "\033[1;32mDetected changes in: $files_changed\033[0m"
        fi

        nixpkgs-fmt "$CFG_DIR"/*.nix "$CFG_DIR"/modules/home/*.nix 2>/dev/null || true

        if sudo nixos-rebuild switch --flake "$CFG_DIR#$TARGET"; then
          git -C "$CFG_DIR" add .
          git -C "$CFG_DIR" commit -m "$msg" || true
          echo -e "\033[1;36m☁ Pushing to GitHub...\033[0m"
          git -C "$CFG_DIR" push
          echo -e "\n\033[1;32m🚀 Update complete: $msg\033[0m\n"
        else
          echo -e "\n\033[1;31m❌ Rebuild failed. No push to GitHub.\033[0m\n"
          return 1
        fi
      }

      # THE MAINTENANCE ENGINE (v1 - Deep Clean & Optimize)
      maintenance() {
        local CFG_DIR=$(_get_nix_config_dir)
        echo -e "\033[1;35m--- Starting Deep System Maintenance ---\033[0m"

        echo -e "\033[1;34m1. Updating Flake inputs...\033[0m"
        nix flake update --flake "$CFG_DIR"

        echo -e "\033[1;34m2. Rebuilding system with updated inputs...\033[0m"
        rebuild "chore: weekly maintenance and flake update"

        echo -e "\033[1;33m3. Collecting Garbage (older than 7 days)...\033[0m"
        sudo nix-collect-garbage --delete-older-than 7d

        echo -e "\033[1;32m4. Optimising Nix Store...\033[0m"
        nix-store --optimise

        echo -e "\033[1;36m✨ Maintenance Complete! System is Golden. ✨\033[0m"
      }

      if [[ $- == *i* ]]; then fastfetch; fi
    '';
  };

  programs.home-manager.enable = true;
}

{ config, pkgs, lib, ... }:

let
  claude-lm = pkgs.writeScriptBin "claude-lm" ''
    #!${pkgs.python3}/bin/python3
    """Launch Claude Code CLI backed by a local LM Studio server."""

    import json
    import os
    import shutil
    import sys
    import urllib.error
    import urllib.request


    def fetch_json(url: str, token: str | None):
        headers = {"Authorization": f"Bearer {token}"} if token else {}
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=3) as resp:
            return json.loads(resp.read().decode("utf-8"))


    def is_embedding(model_type: str, model_id: str) -> bool:
        return "embed" in model_type.lower() or "embed" in model_id.lower()


    def detect_loaded_model(base_url: str, token: str | None):
        available = []
        try:
            data = fetch_json(f"{base_url}/api/v1/models", token)
            if isinstance(data, dict) and isinstance(data.get("models"), list):
                for m in data["models"]:
                    mtype = str(m.get("type", ""))
                    mkey = str(m.get("key") or m.get("id") or "")
                    if not mkey or is_embedding(mtype, mkey):
                        continue
                    available.append(mkey)
                    instances = m.get("loaded_instances") or []
                    if isinstance(instances, list) and instances:
                        inst = instances[0] if isinstance(instances[0], dict) else {}
                        model_id = inst.get("id") or mkey
                        cfg = inst.get("config") if isinstance(inst.get("config"), dict) else {}
                        ctx = cfg.get("context_length")
                        ctx_len = int(ctx) if isinstance(ctx, int) and ctx > 0 else None
                        return str(model_id), ctx_len, available
                return None, None, available
        except urllib.error.HTTPError:
            pass

        try:
            data = fetch_json(f"{base_url}/api/v0/models", token)
            if isinstance(data, dict) and isinstance(data.get("data"), list):
                for m in data["data"]:
                    mtype = str(m.get("type", ""))
                    mid = str(m.get("id") or "")
                    if not mid or is_embedding(mtype, mid):
                        continue
                    available.append(mid)
                    if m.get("state") == "loaded":
                        ctx = m.get("loaded_context_length")
                        ctx_len = int(ctx) if isinstance(ctx, int) and ctx > 0 else None
                        return mid, ctx_len, available
                return None, None, available
        except urllib.error.HTTPError:
            pass

        data = fetch_json(f"{base_url}/v1/models", token)
        if isinstance(data, dict) and isinstance(data.get("data"), list):
            for m in data["data"]:
                mid = str(m.get("id") or "")
                if mid and not is_embedding("", mid):
                    available.append(mid)
            if available:
                return available[0], None, available
        return None, None, available


    def extract_cli_model(args):
        for i, arg in enumerate(args):
            if arg in ("--model", "-m") and i + 1 < len(args):
                return args[i + 1]
            if arg.startswith("--model="):
                return arg.split("=", 1)[1]
        return None


    def main() -> int:
        args = sys.argv[1:]
        base_url = os.environ.get("LMSTUDIO_URL", "http://localhost:1234").rstrip("/")
        if base_url.endswith("/v1"):
            base_url = base_url[:-3]
        token = os.environ.get("LM_API_TOKEN") or os.environ.get("ANTHROPIC_AUTH_TOKEN") or "lmstudio"

        claude_bin = shutil.which("claude")
        if not claude_bin:
            print("Error: claude binary not found on PATH.", file=sys.stderr)
            return 1

        if any(a in ("-h", "--help", "-v", "--version") for a in args):
            os.execv(claude_bin, [claude_bin, *args])

        cli_model = extract_cli_model(args)
        model = cli_model
        ctx_len = None

        if not model:
            try:
                model, ctx_len, available = detect_loaded_model(base_url, token)
            except (urllib.error.URLError, TimeoutError, ConnectionError) as exc:
                print(f"Could not connect to LM Studio at {base_url} ({exc}).", file=sys.stderr)
                print("Start LM Studio, load a model, and toggle Local Server ON (Developer tab).", file=sys.stderr)
                return 1
            if not model:
                print(f"LM Studio is running at {base_url}, but no LLM is loaded.", file=sys.stderr)
                for m in available[:10]:
                    print(f"  - {m}", file=sys.stderr)
                return 1

        env = os.environ.copy()
        env.pop("ANTHROPIC_API_KEY", None)
        override_env = {
            "ANTHROPIC_BASE_URL": base_url,
            "ANTHROPIC_AUTH_TOKEN": token,
            "CLAUDE_CODE_ATTRIBUTION_HEADER": "0",
            "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
            "ANTHROPIC_MODEL": model,
            "ANTHROPIC_DEFAULT_SONNET_MODEL": model,
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": model,
            "ANTHROPIC_DEFAULT_OPUS_MODEL": model,
        }
        if ctx_len and ctx_len >= 100000 and "CLAUDE_CODE_AUTO_COMPACT_WINDOW" not in env:
            override_env["CLAUDE_CODE_AUTO_COMPACT_WINDOW"] = str(ctx_len)

        env.update(override_env)
        print(f"Launching Claude Code with LM Studio ({base_url}) -> {model}", file=sys.stderr)

        cmd = [claude_bin]
        if "--settings" not in args:
            cmd.extend(["--settings", json.dumps({"env": override_env})])
        if not cli_model:
            cmd.extend(["--model", model])
        cmd.extend(args)

        os.execve(claude_bin, cmd, env)
        return 0


    if __name__ == "__main__":
        raise SystemExit(main())
  '';
in
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
    claude-lm
  ]
  ++ lib.optionals (pkgs ? colloid-icon-theme) [ pkgs.colloid-icon-theme ]
  ++ lib.optionals (pkgs ? claude-code) [ pkgs.claude-code ]
  ++ lib.optionals (pkgs ? lmstudio) [ pkgs.lmstudio ];

  # --- SYSTEM-WIDE GTK & QT ICONS (Colloid-Dark) ---
  gtk = {
    enable = true;
    iconTheme = lib.mkIf (pkgs ? colloid-icon-theme) {
      name = "Colloid-Dark";
      package = pkgs.colloid-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4 = {
      theme = null;
      extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };
  };

  home.file.".config/qt5ct/qt5ct.conf".text = ''
    [Appearance]
    icon_theme=Colloid-Dark
    standard_dialogs=gtk3
    style=Fusion

    [Fonts]
    fixed="JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0"
    general="JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0"
  '';

  home.file.".config/qt6ct/qt6ct.conf".text = ''
    [Appearance]
    icon_theme=Colloid-Dark
    standard_dialogs=gtk3
    style=Fusion

    [Fonts]
    fixed="JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0"
    general="JetBrainsMono Nerd Font,10,-1,5,50,0,0,0,0,0"
  '';

  # --- CLAUDE CODE (LM STUDIO) & CLAUDE DESKTOP KEYRING FIX ---
  home.file.".claude/settings.json".text = builtins.toJSON {
    theme = "auto";
    env = {
      ANTHROPIC_BASE_URL = "http://localhost:1234";
      ANTHROPIC_AUTH_TOKEN = "lmstudio";
      CLAUDE_CODE_ATTRIBUTION_HEADER = "0";
      CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1";
    };
  };

  home.file.".config/claude-desktop-flags.conf".text = ''
    --password-store=gnome-libsecret
  '';

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
      email = "turnejac01@gmail.com";
    };
  };

  # --- FISH SHELL (Synced with Arch setup) ---
  programs.fish = {
    enable = true;
    shellAliases = {
      gs = "git status";
      ll = "ls -lah";
      config = "git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME";
    };
    interactiveShellInit = ''
      set -g fish_greeting ""
      set -g fish_prompt_pwd_dir_length 0
      set -gx EDITOR nvim
      set -gx VISUAL nvim
      if type -q fastfetch
        fastfetch
      end
    '';
    functions = {
      nrs = ''
        set -l cfg "$HOME/GitHub/nixos-config"
        if test -d "$HOME/nixos-config/.git"; set cfg "$HOME/nixos-config"; end
        set -l target nixos
        if systemd-detect-virt -q 2>/dev/null; set target vm; end
        git -C "$cfg" add . 2>/dev/null; or true
        sudo nixos-rebuild switch --flake "$cfg#$target" $argv
      '';
      hms = "nrs $argv";
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

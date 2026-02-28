{ config, pkgs, ... }:

{
  home.username = "jacob";
  home.homeDirectory = "/home/jacob";
  home.stateVersion = "25.11";

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # Neovim & LazyVim Support
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
    nixpkgs-fmt # Standard formatter for your nix files

    # Productivity & Creative
    firefox
    kdePackages.kate
    shellcheck
    pandoc
    symbola
    nerd-fonts.symbols-only
  ];

  home.file = {
    # Silence Neovide noise
    ".config/neovide/config.toml".text = "fork = true";

    # Custom Fastfetch Config (Chris Titus Style)
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
          { "type": "wmtheme", "key": "│ ├󰉼", "keyColor": "blue" },
          { "type": "icons", "key": "│ ├󰀻", "keyColor": "blue" },
          { "type": "cursor", "key": "│ ├", "keyColor": "blue" },
          { "type": "terminal", "key": "│ └", "keyColor": "blue" },
          { "type": "cpu", "key": "│ ├󰻠", "keyColor": "green" },
          { "type": "gpu", "key": "│ ├󰻑", "keyColor": "green" },
          { "type": "display", "key": "│ ├󰍹", "keyColor": "green", "compactType": "original-with-refresh-rate" },
          { "type": "memory", "key": "│ ├󰾆", "keyColor": "green" },
          { "type": "uptime", "key": "│ ├󰅐", "keyColor": "green" },
          { "type": "sound", "key": " AUDIO", "format": "{2}", "keyColor": "magenta" },
          { "type": "media", "key": "│ └󰝚", "keyColor": "magenta" },
          { "type": "custom", "format": "\u001b[90m  \u001b[31m  \u001b[32m  \u001b[33m  \u001b[34m  \u001b[35m  \u001b[36m  \u001b[37m  \u001b[38m  \u001b[39m  \u001b[39m    \u001b[38m  \u001b[37m  \u001b[36m  \u001b[35m  \u001b[34m  \u001b[33m  \u001b[32m  \u001b[31m  \u001b[90m " },
          "break"
        ]
      }
    '';
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      # The Super Sync Function
      # Usage: gsync "your commit message"
      gsync() {
        nixpkgs-fmt ~/nixos-config/*.nix && \
        sudo nixos-rebuild switch --flake ~/nixos-config#nixos && \
        git add . && \
        git commit -m "$1" && \
        git push && \
        echo -e "\n\033[1;32m🚀 Golden Build Synced Successfully!\033[0m\n"
      }

      # Run showcase on every new terminal
      showcase
    '';

    shellAliases = {
      # Build & Maintenance
      rebuild = "nixpkgs-fmt ~/nixos-config/*.nix && sudo nixos-rebuild switch --flake ~/nixos-config#nixos";
      cleanup = "sudo nix-collect-garbage --delete-older-than 7d";
      listgens = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";

      # Fixed the quoting here to prevent EOF errors
      showcase = "fastfetch && echo \"\" && tree ~/nixos-config";

      # Quick Edit Shortcuts
      editconf = "neovide ~/nixos-config/configuration.nix > /dev/null 2>&1 & disown";
      edithome = "neovide ~/nixos-config/home.nix > /dev/null 2>&1 & disown";
      editapps = "neovide ~/nixos-config/system-apps.nix > /dev/null 2>&1 & disown";

      # Tooling
      doom = "/home/jacob/.config/emacs/bin/doom";
      l = "ls -alh";
      ll = "ls -l";
    };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    userName = "jacobdt23";
    userEmail = "turnerjac01@gmail.com";
  };

  programs.home-manager.enable = true;
}

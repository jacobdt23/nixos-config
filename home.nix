{ config, pkgs, ... }:

{
  home.username = "jacob";
  home.homeDirectory = "/home/jacob";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [];

  # --- CUSTOM FASTFETCH ---
  home.file.".config/fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "logo": { "padding": { "top": 1 } },
      "display": { "separator": " 󰑃  " },
      "modules": [
        "break",
        { "type": "os", "key": " DISTRO", "keyColor": "yellow" },
        { "type": "kernel", "key": "│ ├", "keyColor": "yellow" },
        { "type": "packages", "key": "│ ├󰏖", "keyColor": "yellow" },
        {
          "type": "command",
          "key": "│ ├",
          "keyColor": "yellow",
          "text": "birth_install=$(stat -c %W /); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo $days_difference days"
        },
        { "type": "shell", "key": "│ └", "keyColor": "yellow" },
        { "type": "wm", "key": " DE/WM", "keyColor": "blue" },
        { "type": "wmtheme", "key": "│ ├󰉼", "keyColor": "blue" },
        { "type": "icons", "key": "│ ├󰀻", "keyColor": "blue" },
        { "type": "cursor", "key": "│ ├", "keyColor": "blue" },
        { "type": "terminalfont", "key": "│ ├", "keyColor": "blue" },
        { "type": "terminal", "key": "│ └", "keyColor": "blue" },
        { "type": "cpu", "key": "│ ├󰻠", "keyColor": "green" },
        { "type": "gpu", "key": "│ ├󰻑", "format": "{2}", "keyColor": "green" },
        { "type": "display", "key": "│ ├󰍹", "keyColor": "green", "compactType": "original-with-refresh-rate" },
        { "type": "memory", "key": "│ ├󰾆", "keyColor": "green" },
        { "type": "uptime", "key": "│ ├󰅐", "keyColor": "green" },
        { "type": "sound", "key": " AUDIO", "format": "{2}", "keyColor": "magenta" },
        { "type": "player", "key": "│ ├󰥠", "keyColor": "magenta" },
        { "type": "media", "key": "│ └󰝚", "keyColor": "magenta" },
        { "type": "custom", "format": "\\u001b[90m  \\u001b[31m  \\u001b[32m  \\u001b[33m  \\u001b[34m  \\u001b[35m  \\u001b[36m  \\u001b[37m  \\u001b[38m  \\u001b[39m  \\u001b[39m    \\u001b[38m  \\u001b[37m  \\u001b[36m  \\u001b[35m  \\u001b[34m  \\u001b[33m  \\u001b[32m  \\u001b[31m  \\u001b[90m " },
        "break"
      ]
    }
  '';

  programs.bash = {
    enable = true;
    shellAliases = {
      # Navigation
      hcfg = "cd ~/GitHub/nixos-config && nano home.nix";
      ncfg = "cd ~/GitHub/nixos-config && nano configuration.nix";
      gh = "cd ~/GitHub";

      # Rebuilds
      nrs = "sudo nixos-rebuild switch --flake ~/GitHub/nixos-config#nixos --impure";
      hms = "sudo nixos-rebuild switch --flake ~/GitHub/nixos-config#nixos --impure";

      # Git (Simplified)
      gadd = "git add .";
      gcm = "git commit -m";
      gpush = "git push";
      gpull = "git pull";

      # Hardware & Apps
      nf = "fastfetch";
      doom-sync = "~/.config/emacs/bin/doom sync";
      stats = "sudo scx_lavd --monitor 1";
      copy-config = "bat ~/GitHub/nixos-config/*.nix | wl-copy";
    };
    initExtra = ''
      rebuild() {
        local HOST=$(hostname)
        git -C ~/GitHub/nixos-config add .
        git -C ~/GitHub/nixos-config commit -m "Rebuild ($HOST)" || true
        sudo nixos-rebuild switch --flake ~/GitHub/nixos-config#$HOST --impure && \
        echo "☁ Pushing to GitHub..." && \
        git -C ~/GitHub/nixos-config push
      }
      if [[ $- == *i* ]]; then fastfetch; fi
    '';
  };

  programs.home-manager.enable = true;
}

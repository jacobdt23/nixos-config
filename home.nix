{ config, pkgs, ... }:

{
  home.username = "jacob";
  home.homeDirectory = "/home/jacob";
  home.stateVersion = "25.11";

  # We keep these here as a minimal set of user-specific tools
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
        { "type": "cpu", "key": "│ ├󰻠", "keyColor": "green" },
        { "type": "gpu", "key": "│ ├󰻑", "format": "{2}", "keyColor": "green" },
        { "type": "memory", "key": "│ ├󰾆", "keyColor": "green" },
        { "type": "sound", "key": " AUDIO", "format": "{2}", "keyColor": "magenta" },
        { "type": "custom", "format": "\u001b[90m  \u001b[31m  \u001b[32m  \u001b[33m  \u001b[34m  \u001b[35m  \u001b[36m  \u001b[37m  \u001b[38m  \u001b[39m  \u001b[39m    \u001b[38m  \u001b[37m  \u001b[36m  \u001b[35m  \u001b[34m  \u001b[33m  \u001b[32m  \u001b[31m  \u001b[90m " },
        "break"
      ]
    }
  '';

  programs.bash = {
    enable = true;
    shellAliases = {
      hcfg = "nano ~/nixos-config/home.nix";
      ncfg = "nano ~/nixos-config/configuration.nix";
      nrs = "sudo nixos-rebuild switch --flake ~/nixos-config#$(hostname) --impure";
      gpush = "git -C ~/nixos-config push";
      # Adding your clipboard shortcut
      copy-config = "bat ~/nixos-config/*.nix | wl-copy";
    };
    initExtra = ''
      function rebuild {
        local HOST=$(hostname)
        git -C ~/nixos-config add .
        git -C ~/nixos-config commit -m "Rebuild ($HOST)" || true
        sudo nixos-rebuild switch --flake ~/nixos-config#$HOST --impure && \
        echo "☁ Pushing to GitHub..." && \
        git -C ~/nixos-config push
      }
      if [[ $- == *i* ]]; then fastfetch; fi
    '';
  };

  programs.home-manager.enable = true;
}

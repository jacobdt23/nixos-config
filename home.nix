{ config, pkgs, ... }:
{
  home.username = "jacob";
  home.homeDirectory = "/home/jacob";
  home.stateVersion = "25.11";
  home.packages = with pkgs; [ fastfetch tree neovide git scx.full ];

  # --- CUSTOM FASTFETCH (Jacob's 2026 Build) ---
  home.file.".config/fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
      "modules": [
        "break",
        { "type": "os", "key": " DISTRO", "keyColor": "yellow" },
        { "type": "kernel", "key": "│ ├", "keyColor": "yellow" },
        { "type": "packages", "key": "│ ├󰏖", "keyColor": "yellow" },
        { "type": "command", "key": "│ ├", "keyColor": "yellow", "text": "birth_install=$(stat -c %W /); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo $days_difference days" },
        { "type": "shell", "key": "│ └", "keyColor": "yellow" },
        { "type": "host", "key": "󰌢 SYSTEM", "keyColor": "green" },
        { "type": "cpu", "key": "│ ├󰻠", "keyColor": "green" },
        { "type": "gpu", "key": "│ ├󰻑", "format": "{2}", "keyColor": "green" },
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
    };
    initExtra = ''
      function rebuild {
        local HOST=$(hostname)
        git -C ~/nixos-config add .
        git -C ~/nixos-config commit -m "Rebuild ($HOST)" || true
        sudo nixos-rebuild switch --flake ~/nixos-config#$HOST --impure && \
        echo "☁️ Pushing to GitHub..." && \
        git -C ~/nixos-config push
      }
      if [[ $- == *i* ]]; then fastfetch; fi
    '';
  };
  programs.home-manager.enable = true;
}

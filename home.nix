{ config, pkgs, ... }:

{
  home.username = "jacob";
  home.homeDirectory = "/home/jacob";
  home.stateVersion = "25.11";

  home.sessionPath = [ "$HOME/.config/emacs/bin" ];

  home.packages = with pkgs; [     
    fastfetch     
    tree
    neovide
    git
    scx.full
  ];

  services.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk; 
    client.enable = true;
  };

# --- FASTFETCH CONFIG (Jacob's Custom Setup) ---
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
        { "type": "terminal", "key": "│ └", "keyColor": "blue" },
        { "type": "cpu", "key": "│ ├󰻠", "keyColor": "green" },
        { "type": "gpu", "key": "│ ├󰻑", "format": "{2}", "keyColor": "green" },
        { "type": "display", "key": "│ ├󰍹", "keyColor": "green", "compactType": "original-with-refresh-rate" },
        { "type": "memory", "key": "│ ├󰾆", "keyColor": "green" },
        { "type": "uptime", "key": "│ ├󰅐", "keyColor": "green" },
        { "type": "sound", "key": " AUDIO", "format": "{2}", "keyColor": "magenta" },
        {
          "type": "custom",
          "format": " \u001b[90m  \u001b[31m  \u001b[32m  \u001b[33m  \u001b[34m  \u001b[35m  \u001b[36m  \u001b[37m  \u001b[38m  \u001b[39m  \u001b[39m    \u001b[38m  \u001b[37m  \u001b[36m  \u001b[35m  \u001b[34m  \u001b[33m  \u001b[32m  \u001b[31m  \u001b[90m "
        },
        "break"
      ]
    }
  '';


  programs.bash = {
    enable = true;
    shellAliases = {
      emacs = "emacsclient -c -a 'emacs'";  
      doom-sync = "/home/jacob/.config/emacs/bin/doom sync";

      # SMART REBUILD: Picks #nixos on desktop and #vm in the VM
      nrs = "sudo nixos-rebuild switch --flake /etc/nixos#$(hostname) --impure";
      
      ncfg = "cd /etc/nixos && nano configuration.nix";
      hcfg = "cd /etc/nixos && nano home.nix";
      nclean = "sudo nix-collect-garbage -d";
      ngen = "nix-env --list-generations";

      # Git Workflow
      gstatus = "git status";
      gadd = "git add .";
      gcm = "git commit -m";
      gpush = "git push";
    };

    initExtra = ''
      function rebuild {
        local HOST=$(hostname)
        echo "🔨 Rebuilding Jacob's Config for host: $HOST"
        git -C /etc/nixos add .
        git -C /etc/nixos commit -m "Rebuild ($HOST): $(date)" || true
        sudo nixos-rebuild switch --flake /etc/nixos#$HOST --impure
      }
      if [[ $- == *i* ]]; then fastfetch; fi
    '';
  };

  programs.home-manager.enable = true;
}

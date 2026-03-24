{ config, pkgs, ... }:

{
  home.username = "jacob";
  home.homeDirectory = "/home/jacob";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [ fastfetch tree neovide git scx.full ];

  # --- FASTFETCH CONFIG ---
  home.file.".config/fastfetch/config.jsonc".text = ''
    {
      "logo": { "padding": { "top": 1 } },
      "display": { "separator": " 󰑃  " },
      "modules": [
        "break",
        { "type": "os", "key": " DISTRO", "keyColor": "yellow" },
        { "type": "kernel", "key": "│ ├", "keyColor": "yellow" },
        { "type": "packages", "key": "│ ├󰏖", "keyColor": "yellow" },
        { "type": "shell", "key": "│ └", "keyColor": "yellow" },
        { "type": "wm", "key": " DE/WM", "keyColor": "blue" },
        { "type": "cpu", "key": "│ ├󰻠", "keyColor": "green" },
        { "type": "gpu", "key": "│ ├󰻑", "format": "{2}", "keyColor": "green" },
        { "type": "memory", "key": "│ ├󰾆", "keyColor": "green" },
        "break"
      ]
    }
  '';

  programs.bash = {
    enable = true;
    shellAliases = {
      hcfg = "cd /etc/nixos && nano home.nix";
      ncfg = "cd /etc/nixos && nano configuration.nix";
      nclean = "sudo nix-collect-garbage -d";
      ngen = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
      nrs = "sudo nixos-rebuild switch --flake /etc/nixos#$(hostname) --impure";
      gstatus = "git status";
      gadd = "git add .";
      gcm = "git commit -m";
      gpush = "git push";
    };
    initExtra = ''
      function rebuild {
        local HOST=$(hostname)
        git -C /etc/nixos add .
        git -C /etc/nixos commit -m "Rebuild ($HOST): $(date)" || true
        sudo nixos-rebuild switch --flake /etc/nixos#$HOST --impure
      }
      if [[ $- == *i* ]]; then fastfetch; fi
    '';
  };

  programs.home-manager.enable = true;
}

{ config, pkgs, ... }:

{
  home.username = "jacob";
  home.homeDirectory = "/home/jacob";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [ fastfetch tree neovide git scx.full ];

  # --- CUSTOM FASTFETCH ---
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
      # Configuration shortcuts
      hcfg = "nano ~/nixos-config/home.nix";
      ncfg = "nano ~/nixos-config/configuration.nix";
      
      # Maintenance fixed for Flakes
      nclean = "sudo nix-collect-garbage -d";
      ngen = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
      
      # Rebuild logic (uses hostname automatically)
      nrs = "sudo nixos-rebuild switch --flake ~/nixos-config#$(hostname) --impure";
      
      # Git logic
      gstatus = "git -C ~/nixos-config status";
      gadd = "git -C ~/nixos-config add .";
      gcm = "git -C ~/nixos-config commit -m";
      gpush = "git -C ~/nixos-config push";
    };
    initExtra = ''
      function rebuild {
        local HOST=$(hostname)
        git -C ~/nixos-config add .
        git -C ~/nixos-config commit -m "Rebuild ($HOST): $(date)" || true
        sudo nixos-rebuild switch --flake ~/nixos-config#$HOST --impure
      }
      if [[ $- == *i* ]]; then fastfetch; fi
    '';
  };

  programs.home-manager.enable = true;
}

{ config, pkgs, ... }:

{
  home.username = "jacob";
  home.homeDirectory = "/home/jacob";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [];

  programs.bash = {
    enable = true;
    shellAliases = {
      hcfg = "cd ~/GitHub/nixos-config && nano home.nix";
      ncfg = "cd ~/GitHub/nixos-config && nano configuration.nix";
      gh = "cd ~/GitHub";
      nrs = "sudo nixos-rebuild switch --flake ~/GitHub/nixos-config#nixos --impure";
      hms = "sudo nixos-rebuild switch --flake ~/GitHub/nixos-config#nixos --impure";
      gadd = "git add .";
      gcm = "git commit -m";
      gpush = "git push";
      gpull = "git pull";
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

{ config, pkgs, ... }:

{
  home.username = "jacob";
  home.homeDirectory = "/home/jacob";
  home.stateVersion = "25.11";

  # Add direnv to your home packages so it's always available
  home.packages = with pkgs; [
    direnv
    nix-direnv
  ];

  programs.bash = {
    enable = true;
    shellAliases = {
      # --- Existing Aliases ---
      hcfg = "cd ~/GitHub/nixos-config && nano home.nix";
      ncfg = "cd ~/GitHub/nixos-config && nano configuration.nix";
      nrs = "sudo nixos-rebuild switch --flake ~/GitHub/nixos-config#nixos --impure";
      
      # --- NEW Website Workflow Aliases ---
      # Automatically starts local server with the correct port override
      web-serve = "cd ~/GitHub/website && hugo server -D -b http://localhost:1313/";
      
      # Quick deploy: Add, Commit, and Push all in one go
      web-deploy = "cd ~/GitHub/website && git add . && git commit -m 'Site Update' && git push";
      
      # Check the status of your GitHub Action build
      web-check = "gh run list --workflow hugo.yaml";
    };
    
    # Enable direnv to auto-load the flake when you enter the directory
    initExtra = ''
      eval "$(direnv hook bash)"
    '';
  };

  programs.home-manager.enable = true;
}

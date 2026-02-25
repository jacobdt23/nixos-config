{ config, pkgs, ... }:

{
  home.username = "jacob";
  home.homeDirectory = "/home/jacob";
  home.stateVersion = "25.11";

  # 1. This handles the 'Symbola' and 'Nerd Font' warnings
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # Doom Muscles
    ripgrep
    fd
    gcc
    unzip
    firefox
    kdePackages.kate
    # Doom Doctor's missing tools
    shellcheck       # Fixes the :lang sh warning
    pandoc           # Best markdown compiler for :lang markdown
    symbola          # Fallback font Doom requested
    nerd-fonts.symbols-only # The specific icons Doom needs
  ];

  # 2. This keeps the 'doom' binary in your path
  home.sessionPath = [
    "$HOME/.config/emacs/bin"
  ];

  programs.bash = {
    enable = true;
  shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config#nixos";
      # Update these to point to your home folder repo:
      editconf = "nano ~/nixos-config/configuration.nix";
      edithome = "nano ~/nixos-config/home.nix";
      editapps = "nano ~/nixos-config/system-apps.nix";
      cleanup = "sudo nix-collect-garbage -d";
      doom = "/home/jacob/.config/emacs/bin/doom";
    };
    };
  # 3. Fix the Git warnings for 25.11
  programs.git = {
    enable = true;
    settings.user = {
      name = "Jacob Turner";
      email = "your-email@example.com"; 
    };
  };

  programs.home-manager.enable = true;
}

{ config, pkgs, ... }:

{
  home.username = "jacob";
  home.homeDirectory = "/home/jacob";
  home.stateVersion = "25.11";

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # LazyVim/Neovim Dependencies
    lua-language-server
    nil                  # Nix Language Server
    stylua               # Lua Formatter
    ripgrep
    fd
    gcc
    unzip
    
    # Personal Apps
    firefox
    kdePackages.kate
    shellcheck
    pandoc
    symbola
    nerd-fonts.symbols-only 
  ];

  # This silences the "Could not watch config file" error
  home.file.".config/neovide/config.toml".text = ''
    fork = true
  '';

  home.sessionPath = [
    "$HOME/.config/emacs/bin"
  ];

  programs.bash = {
    enable = true;
    shellAliases = {
      # System Management
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config#nixos";
      gsync = "git add . && git commit -m \"Sync: $(date +'%Y-%m-%d %H:%M:%S')\" && git push";      
      cleanup = "sudo nix-collect-garbage --delete-older-than 7d";
      listgens = "sudo nix-env --list-generations --profile /nix/var/nix/profiles/system";
      
      # Corrected Silent GUI Aliases
      editconf = "neovide ~/nixos-config/configuration.nix > /dev/null 2>&1 & disown";
      edithome = "neovide ~/nixos-config/home.nix > /dev/null 2>&1 & disown";
      editapps = "neovide ~/nixos-config/system-apps.nix > /dev/null 2>&1 & disown";
      doom = "/home/jacob/.config/emacs/bin/doom";
    };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings.user = {
      name = "jacobdt23";
      email = "turnejac01@gmail.com";  
    };
  };

  programs.home-manager.enable = true;
}

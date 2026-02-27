{ config, pkgs, ... }:

{
  home.username = "jacob";
  home.homeDirectory = "/home/jacob";
  home.stateVersion = "25.11";

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # Dependencies for Neovim/LazyVim
    lua-language-server
    nil                  # Nix Language Server
    stylua               # Lua Formatter
    
    # Existing Tools
    ripgrep
    fd
    gcc
    unzip
    firefox
    kdePackages.kate
    shellcheck
    pandoc
    symbola
    nerd-fonts.symbols-only 
  ];

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
      
      # GUI Editing Aliases (Neovide)
      editconf = "neovide ~/nixos-config/configuration.nix & disown";
      edithome = "neovide ~/nixos-config/home.nix & disown";
      editapps = "neovide ~/nixos-config/system-apps.nix & disown";
      
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

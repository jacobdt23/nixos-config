{ config, pkgs, ... }:

{
  home.username = "jacob";
  home.homeDirectory = "/home/jacob";
  home.stateVersion = "25.11";

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    # Neovim & LazyVim Support
    lua-language-server
    nil
    stylua
    ripgrep
    fd
    gcc
    unzip

    # Titus Fetch Tools
    fastfetch
    pciutils

    # Existing Apps
    firefox
    kdePackages.kate
    shellcheck
    pandoc
    symbola
    nerd-fonts.symbols-only 
  ];

  # Silences Neovide and creates the Titus Fetch config
  home.file = {
    ".config/neovide/config.toml".text = "fork = true";
    
    ".config/fastfetch/config.jsonc".text = ''
      {
        "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
        "logo": {
            "type": "small",
            "padding": { "top": 2, "left": 2 }
        },
        "display": {
            "separator": " ➜  ",
            "color": "magenta"
        },
        "modules": [
            "title",
            "separator",
            "os",
            "host",
            "kernel",
            "uptime",
            "packages",
            "shell",
            "display",
            "de",
            "wm",
            "terminal",
            "cpu",
            "gpu",
            "memory",
            "break",
            "colors"
        ]
      }
    '';
  };

  programs.bash = {
    enable = true;
    # Auto-run fetch on terminal start
    initExtra = "fastfetch";
    
    shellAliases = {
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

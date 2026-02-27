{ pkgs, ... }:

{
  # Allow unfree software for things like Steam or proprietary drivers
  nixpkgs.config.allowUnfree = true;

  # Neovim Wrapper Configuration
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  environment.systemPackages = with pkgs; [
    # Neovim GUI
    neovide
    
    # System Tools
    kdePackages.kate
    firefox
    git
    github-desktop        
    emacs       
    wget
    curl
    pciutils
    fastfetch
    protonup-qt   
    mangohud          
    nvtopPackages.full
    goverlay
    vulkan-tools
    gnome-disk-utility   
  ];

  # Enable Steam (system-level)
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}

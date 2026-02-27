{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  environment.systemPackages = with pkgs; [
    neovide
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
    tree   
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}

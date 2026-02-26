{ pkgs, ... }:

{
  # Allow unfree software for things like Steam or proprietary drivers
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    kdePackages.kate
    firefox
    git
    github-desktop    
    emacs   
    neovim
    wget
    curl
    pciutils
    fastfetch
    protonup-qt  
    mangohud     
    nvtopPackages.full
    goverlay
    vulkan-tools 
  ];

  # Enable Steam (system-level)
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}

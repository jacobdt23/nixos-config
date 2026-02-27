{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  # Neovim Wrapper: Makes 'vi' and 'vim' call Neovim
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  environment.systemPackages = with pkgs; [
    neovide           # The hardware-accelerated GUI
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

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}

{ pkgs, ... }:

{
  # Allow unfree software for things like Steam or proprietary drivers
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    kdePackages.kate
    firefox
    git    
    emacs   
    neovim
    wget
    curl
    pciutils
    fastfetch
  ];

  # Enable Steam (system-level)
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
}

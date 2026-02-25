{ pkgs, ... }:

{
  # Allow unfree software for things like Steam or proprietary drivers
  nixpkgs.config.allowUnfree = true;

packages = with pkgs; [
     kdePackages.kate
     firefox
     git   
     emacs  
     neovim
   ];
 };    


  # Enable Steam (system-level)
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
}

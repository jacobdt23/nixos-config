{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mangohud
    gamemode
    protonup-qt
    scx.full
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.gamemode.enable = true;
}

{ pkgs, lib, config, ... }:

{
  environment.systemPackages = with pkgs; [
    (if lib.elem "nvidia" config.services.xserver.videoDrivers
     then nvtopPackages.full
     else nvtopPackages.amd)
    emacs
    github-cli
    hugo
    virt-viewer
    spice-gtk
    bat
    fastfetch
    tree
    wget
    curl
    git
    ripgrep
    fd
    wl-clipboard
    nixpkgs-fmt
    neovim-qt
    gcc
    gnumake
    tree-sitter
    tmux
    brave
    discord
    kdePackages.kate
    github-desktop
  ];
}

{
  description = "HyprFrost NixOS — Jacob's Omarchy-esque NixOS configuration & custom ISO";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      # Reusable module for applying the HyprFrost NixOS desktop on other NixOS hosts
      nixosModules.hyprfrost = ./configuration.nix;

      nixosConfigurations = {
        # --- BARE METAL HOST (Main Desktop: 7800X3D / RTX 5070) ---
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./configuration.nix
            ./hardware-configuration.nix
            ./nvidia.nix
            ./creative.nix
            ./gaming.nix
            home-manager.nixosModules.home-manager
          ];
        };

        # --- VIRTUAL MACHINE (Test Lab) ---
        vm = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./configuration.nix
            (if builtins.pathExists ./hardware-configuration.nix
             then ./hardware-configuration.nix
             else ./vm-hardware.nix)
            home-manager.nixosModules.home-manager
            {
              networking.hostName = "vm";
              users.users.jacob.password = "nixos";
              virtualisation.vmVariant = {
                virtualisation = {
                  memorySize = 4096;
                  cores = 4;
                  graphics = true;
                  resolution = { x = 1920; y = 1080; };
                  qemu.options = [
                    "-vga virtio"
                    "-display vnc=0.0.0.0:0,websocket=5700"
                  ];
                };
                environment.sessionVariables = {
                  WLR_RENDERER_ALLOW_SOFTWARE = "1";
                  WLR_NO_HARDWARE_CURSORS = "1";
                };
              };
            }
          ];
        };

        # --- CUSTOM BOOTABLE LIVE ISO (HyprFrost NixOS + Calamares + Hyprland) ---
        iso = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./configuration.nix
            ./iso.nix
            home-manager.nixosModules.home-manager
          ];
        };
      };

      # Shorthand package target: `nix build .#iso`
      packages.${system}.iso =
        self.nixosConfigurations.iso.config.system.build.isoImage;
    };
}

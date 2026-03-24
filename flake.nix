{
  description = "Jacob's Universal NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      # --- BARE METAL HOST (7800X3D Rig) ---
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          ./hardware-configuration.nix
          ./nvidia.nix
          home-manager.nixosModules.home-manager
        ];
      };

      # --- VIRTUAL MACHINE (The Lab) ---
      vm = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          ./vm-hardware.nix
          home-manager.nixosModules.home-manager
          {
            networking.hostName = "vm";
          }
        ];
      };
    };
  };
}

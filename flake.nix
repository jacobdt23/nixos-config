{
  description = "Jacob's Universal NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # UPDATED URL HERE:
    nix-cachyos-kernel.url = "github:CachyOS/nix-cachyos-kernel";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          ./hardware-configuration.nix
          ./nvidia.nix
          home-manager.nixosModules.home-manager
        ];
      };

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

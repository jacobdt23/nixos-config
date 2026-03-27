{
  description = "Jacob's Universal NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      # --- BARE METAL HOST (Your Main Desktop) ---
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          ./hardware-configuration.nix # Loads physical drives
          ./nvidia.nix # Loads physical GPU drivers
          home-manager.nixosModules.home-manager
        ];
      };

      # --- VIRTUAL MACHINE (The Lab) ---
      vm = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          ./vm-hardware.nix # Loads virtual drive only
          home-manager.nixosModules.home-manager
          {
            # Overrides hostname to "vm" locally
            networking.hostName = "vm";
          }
        ];
      };
    };
  };
}

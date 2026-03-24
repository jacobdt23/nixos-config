{
  description = "Jacob's Universal NixOS Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-cachyos-kernel.url = "github:googleson78/nix-cachyos-kernel";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      # --- BARE METAL HOST (RTX 5070 Rig) ---
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          ./hardware-configuration.nix # Real NVMe/SSD
          ./nvidia.nix                # Real GPU Drivers
          home-manager.nixosModules.home-manager
        ];
      };

      # --- VIRTUAL MACHINE (The Lab) ---
      vm = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          ./vm-hardware.nix           # Virtual Drive Only
          home-manager.nixosModules.home-manager
          {
            networking.hostName = "vm";
          }
        ];
      };
    };
  };
}


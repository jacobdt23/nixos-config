{
  description = "Jacob's Golden Build - Multi-Host Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-cosmic, ... }@inputs: {
    nixosConfigurations = {
      # --- THE MAIN RIG (7800X3D / RTX 5070) ---
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          ./hardware-configuration.nix 
          ./nvidia.nix      
          ./creative.nix    
          nixos-cosmic.nixosModules.default
          home-manager.nixosModules.home-manager
        ];
      };

      # --- THE VM TESTER (Hyper-V) ---
      vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          ./hardware-configuration.nix
          nixos-cosmic.nixosModules.default
          home-manager.nixosModules.home-manager
          ({ lib, ... }: {
            networking.hostName = "nixos-vm";
            virtualisation.hypervGuest.enable = true;
          })
        ];
      };
    };
  };
}

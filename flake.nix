{
  description = "Jacob's Golden Build - Dual Personality (Desktop & VM)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-cosmic, nix-cachyos-kernel, ... }@inputs: {
    nixosConfigurations = {
      
      # --- HOST: NIXOS (Your 7800X3D + RTX 5070 Rig) ---
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ({ ... }: { nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.default ]; })
          ./configuration.nix
          ./hardware-configuration.nix
          ./nvidia.nix 
          ./creative.nix
          nixos-cosmic.nixosModules.default
          home-manager.nixosModules.home-manager
        ];
      };

      # --- HOST: VM (Your YouTube Tutorial Environment) ---
      vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          ./vm-hardware.nix 
          ./creative.nix
          nixos-cosmic.nixosModules.default
          home-manager.nixosModules.home-manager
          # This override ensures the VM stays named 'vm' regardless of configuration.nix
          ({ ... }: { networking.hostName = "vm"; })
        ];
      };
    };
  };
}
